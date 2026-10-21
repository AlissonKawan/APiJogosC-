param([string]$BaseUrl = 'http://localhost:5100')

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$client = [System.Net.Http.HttpClient]::new($handler)
$client.BaseAddress = [Uri]$BaseUrl
$client.Timeout = [TimeSpan]::FromSeconds(15)
$script:verificacoes = 0

function Verificar([bool]$Condicao, [string]$Cenario) {
    if (-not $Condicao) { throw "Falhou: $Cenario" }
    $script:verificacoes++
    Write-Output "OK: $Cenario"
}

function Obter([string]$Rota) {
    $resposta = $client.GetAsync($Rota).GetAwaiter().GetResult()
    try {
        return @{
            Status = [int]$resposta.StatusCode
            Html = [System.Net.WebUtility]::HtmlDecode($resposta.Content.ReadAsStringAsync().GetAwaiter().GetResult())
        }
    } finally { $resposta.Dispose() }
}

function Enviar([string]$Rota, [hashtable]$Campos, [bool]$ComToken = $true) {
    $formulario = Obter '/Jogos/Create'
    $dados = [System.Collections.Generic.Dictionary[string,string]]::new()
    foreach ($campo in $Campos.Keys) { $dados[$campo] = [string]$Campos[$campo] }
    if ($ComToken) {
        $token = [regex]::Match($formulario.Html, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"').Groups[1].Value
        if (-not $token) { throw 'Token antiforgery ausente.' }
        $dados['__RequestVerificationToken'] = $token
    }
    $conteudo = [System.Net.Http.FormUrlEncodedContent]::new($dados)
    $resposta = $client.PostAsync($Rota, $conteudo).GetAwaiter().GetResult()
    try {
        return @{
            Status = [int]$resposta.StatusCode
            Html = [System.Net.WebUtility]::HtmlDecode($resposta.Content.ReadAsStringAsync().GetAwaiter().GetResult())
        }
    } finally {
        $resposta.Dispose()
        $conteudo.Dispose()
    }
}

$nome = 'Teste MVC ' + [Guid]::NewGuid().ToString('N')
$valido = @{ Nome = $nome; Preco = '49.90'; DataLancamento = '2024-03-15'; Genero = '1' }
$id = $null

try {
    Verificar ((Obter '/').Status -eq 200) 'Biblioteca acessivel'
    $vazio = Obter ('/Jogos?nome=' + [Uri]::EscapeDataString($nome))
    Verificar ($vazio.Html.Contains('Nenhum jogo encontrado')) 'Pesquisa sem resultados'

    $invalido = Enviar '/Jogos/Create' @{ Nome = ''; Preco = '0'; DataLancamento = ''; Genero = '-1' }
    Verificar ($invalido.Status -eq 200 -and $invalido.Html.Contains('Informe o nome do jogo.') -and $invalido.Html.Contains('O preço deve ser') -and $invalido.Html.Contains('Selecione um gênero válido.') -and $invalido.Html.Contains('Informe um valor válido para')) 'Validacao no servidor dos campos vazios e preco zero'
    $ausentes = Enviar '/Jogos/Create' @{}
    Verificar ($ausentes.Status -eq 200 -and $ausentes.Html.Contains('Informe o campo Preco.') -and $ausentes.Html.Contains('Informe o campo DataLancamento.') -and $ausentes.Html.Contains('Informe o campo Genero.')) 'Campos omitidos rejeitados pelo model binding'
    foreach ($caso in @(
        @{ Campo = 'Preco'; Valor = '-1'; Mensagem = 'O preço deve ser' },
        @{ Campo = 'Preco'; Valor = 'abc'; Mensagem = 'Informe um valor válido para' },
        @{ Campo = 'DataLancamento'; Valor = '2024-02-30'; Mensagem = 'Informe um valor válido para' },
        @{ Campo = 'Genero'; Valor = '999'; Mensagem = 'Informe um valor válido para' },
        @{ Campo = 'Nome'; Valor = ('a' * 121); Mensagem = 'O nome deve ter no máximo 120 caracteres.' }
    )) {
        $campos = $valido.Clone()
        $campos[$caso.Campo] = $caso.Valor
        $resultado = Enviar '/Jogos/Create' $campos
        Verificar ($resultado.Status -eq 200 -and $resultado.Html.Contains($caso.Mensagem)) ("Entrada invalida rejeitada: " + $caso.Campo + ' = ' + $caso.Valor)
    }
    Verificar ((Enviar '/Jogos/Create' $valido $false).Status -eq 400) 'POST sem antiforgery bloqueado'
    Verificar ((Enviar '/Jogos/Create' $valido).Status -eq 302) 'Cadastro valido redireciona (Post/Redirect/Get)'
    $lista = Obter ('/Jogos?nome=' + [Uri]::EscapeDataString($nome))
    $id = [int][regex]::Match($lista.Html, '/Jogos/Details/(\d+)').Groups[1].Value
    Verificar ($id -gt 0 -and $lista.Html.Contains('R$ 49,90')) 'Id automatico e preco decimal preservado'
    $recarregada = Obter ('/Jogos?nome=' + [Uri]::EscapeDataString($nome))
    Verificar ([regex]::Matches($recarregada.Html, 'aria-label="Detalhes de ').Count -eq 1) 'Atualizar a listagem nao duplica o cadastro'
    Verificar ((Obter "/Jogos/Details/$id").Html.Contains($nome)) 'Detalhes retornam o jogo'
    Verificar ((Obter "/Jogos/Edit/$id").Html.Contains('value="49.90"')) 'Edicao preenche o valor no formato HTML'

    $edicao = $valido.Clone()
    $edicao.Id = $id
    $edicao.Nome = $nome + ' Editado'
    $edicao.Preco = '79.99'
    $adulterado = $edicao.Clone()
    $adulterado.Id = $id + 100000
    Verificar ((Enviar "/Jogos/Edit/$id" $adulterado).Status -eq 404) 'Id adulterado na edicao rejeitado'
    $edicaoInvalida = $edicao.Clone()
    $edicaoInvalida.Preco = '0'
    Verificar ((Enviar "/Jogos/Edit/$id" $edicaoInvalida).Status -eq 200 -and (Obter "/Jogos/Details/$id").Html.Contains('R$ 49,90')) 'Edicao invalida preserva registro original'
    Verificar ((Enviar "/Jogos/Edit/$id" $edicao).Status -eq 302) 'Edicao valida redireciona'
    $detalhes = Obter "/Jogos/Details/$id"
    Verificar ($detalhes.Html.Contains($edicao.Nome) -and $detalhes.Html.Contains('R$ 79,99')) 'Edicao atualiza o mesmo registro'
    $busca = Obter ('/Jogos?nome=' + [Uri]::EscapeDataString($nome.ToUpperInvariant()))
    Verificar ($busca.Html.Contains($edicao.Nome)) 'Pesquisa ignora maiusculas e minusculas'

    $confirmacao = Obter "/Jogos/Delete/$id"
    Verificar ($confirmacao.Html.Contains('Confirmar exclusão') -and (Obter "/Jogos/Details/$id").Status -eq 200) 'GET de exclusao apenas exibe confirmacao'
    Verificar ((Obter '/Jogos').Html.Contains($edicao.Nome)) 'Voltar para a lista sem POST preserva o jogo'
    Verificar ((Enviar "/Jogos/Delete/$id" @{} $false).Status -eq 400) 'Exclusao sem antiforgery bloqueada'
    Verificar ((Enviar "/Jogos/Delete/$id" @{ Id = $id }).Status -eq 302) 'Exclusao confirmada redireciona'
    Verificar ((Obter "/Jogos/Details/$id").Status -eq 404) 'Registro excluido nao existe'
    Verificar ((Enviar "/Jogos/Delete/$id" @{ Id = $id }).Status -eq 404) 'Repetir exclusao retorna 404'
    foreach ($rota in @('/Jogos/Details/999999', '/Jogos/Edit/999999', '/Jogos/Delete/999999', '/Jogos/Details/abc', '/Jogos/Details/0', '/Jogos/Details/-1')) {
        Verificar ((Obter $rota).Status -eq 404) ("Identificador invalido ou inexistente: $rota")
    }
    Verificar ((Enviar '/Jogos/Edit/999999' @{ Id = '999999' }).Status -eq 404) 'POST de edicao inexistente retorna 404'
    Verificar ((Obter '/Home/Index').Status -eq 302) 'Home encaminha para biblioteca funcional'
    Write-Output "Concluido: $script:verificacoes verificacoes HTTP passaram."
} finally {
    if ($id -and (Obter "/Jogos/Details/$id").Status -eq 200) {
        $null = Enviar "/Jogos/Delete/$id" @{ Id = $id }
    }
    $client.Dispose()
    $handler.Dispose()
}
