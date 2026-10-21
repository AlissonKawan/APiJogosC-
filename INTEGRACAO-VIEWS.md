# ApiJogosMVC — integração e explicação do back-end

## Resultado

O projeto usa ASP.NET Core MVC com Razor Views e um CRUD de jogos em memória. Não há banco de dados, Entity Framework, arquivo de dados, autenticação, JWT ou API externa. O layout GameVault foi preservado.

A biblioteca abre em `/` e em `/Jogos`. `/Home/Index` redireciona para ela. Os perfis de hospedagem originais continuam em `Properties/launchSettings.json`.

## Arquivos desta implementação

Criados:

- `Controllers/JogosController.cs`: ações de listagem, pesquisa, cadastro, detalhes, edição e exclusão.
- `Services/JogoService.cs`: lista em memória, geração de IDs e operações protegidas por `lock`.
- `scripts/Validar-Crud.ps1`: roteiro reproduzível de testes HTTP, sem dependências de terceiros.

Modificados:

- `Models/JogoModel.cs`: DataAnnotations em português e data como `DateTime`, conforme a tarefa. Mantidos `Id`, `Nome`, `Preco` e `Genero` com propriedades públicas.
- `Models/GeneroEnum.cs`: reutilizado o enum existente; acrescentados os nomes de exibição e a opção inválida `NaoSelecionado = -1`. Os gêneros existentes conservam os valores de 0 a 8, inclusive Luta.
- `Program.cs`: registro Singleton, mensagens de model binding, cultura para os formulários e rota padrão para a biblioteca.
- `Controllers/HomeController.cs`: encaminhamento da antiga prévia para a biblioteca funcional. Privacy e Error continuam disponíveis.
- `Views/Jogos/_JogoForm.cshtml`: select de gênero compartilhado por cadastro e edição, com mensagens de validação.
- `Views/Jogos/Create.cshtml`: texto de apoio inclui gênero.
- `Views/Jogos/Index.cshtml`, `Details.cshtml` e `Delete.cshtml`: apresentação do gênero.
- `INTEGRACAO-VIEWS.md`: esta documentação substitui o antigo roteiro de integração pendente.

Os arquivos de layout, CSS, Tag Helper de preço, imports e as demais Views que já estavam alterados no diretório foram reaproveitados. Essas alterações anteriores não foram recriadas por esta implementação.

## Como explicar o MVC ao professor

O navegador pede uma URL. A rota identifica uma ação do `JogosController`. O controller consulta o `JogoService`, recebe objetos `JogoModel` e entrega esses dados à View correspondente. O Razor gera o HTML que o navegador exibe.

No cadastro, `Create` com GET entrega o formulário. Quando o usuário o envia, o ASP.NET associa os nomes dos campos às propriedades do `JogoModel`: esse processo é o **model binding**. Por exemplo, `asp-for="Preco"` gera o campo cujo nome permite preencher `jogo.Preco`.

O framework converte os valores recebidos e aplica as DataAnnotations. Erros de conversão e de validação ficam em `ModelState`. Se `ModelState.IsValid` for falso, o controller retorna a mesma View com os valores digitados e as mensagens. Nenhum dado é gravado nesse caso.

Se os dados forem válidos, o controller chama o serviço e redireciona à listagem. Esse fluxo **Post/Redirect/Get** faz com que atualizar a página da biblioteca repita um GET, evitando reenviar o cadastro. Ele não bloqueia dois envios deliberados do mesmo formulário nem proíbe jogos com nomes iguais.

## Modelo e validação

- Nome obrigatório, com até 120 caracteres. Espaços nas extremidades são retirados ao armazenar.
- Preço decimal de pelo menos R$ 0,01.
- Data de lançamento obrigatória, sem proibir lançamentos futuros.
- Gênero obrigatório e definido no enum; a opção inicial `-1` não pode ser cadastrada.
- `[BindRequired]` impede que preço, data e gênero omitidos do POST sejam aceitos como os valores padrão dos tipos não anuláveis. Campos vazios ou textos incompatíveis também geram erros de binding.

`asp-validation-for` exibe o erro de cada campo, e `asp-validation-summary` apresenta erros gerais. Os scripts existentes oferecem validação no navegador. A validação no servidor continua obrigatória e foi testada com requisições diretas, sem depender desses scripts.

Os campos HTML `number` enviam números com ponto decimal. O processamento usa `en-US` para conservar esse formato, inclusive ao preencher a edição. A interface continua em português: `PrecoTagHelper` apresenta valores com `pt-BR`, como `R$ 59,90`, e as Views formatam datas em português. Isso evita interpretar `59.90` como `5990` em um ambiente configurado com vírgula decimal.

## Por que Singleton e como a lista funciona

Controllers são criados para atender requisições. Se cada controller criasse sua própria lista, os jogos não estariam disponíveis na próxima requisição.

`AddSingleton<JogoService>()` mantém uma única instância do serviço durante a execução da aplicação. Todos os controllers recebem essa mesma instância por injeção de dependências. A lista privada `List<JogoModel>` fica nessa instância, inicialmente vazia.

O serviço gera IDs sequenciais no cadastro, independentemente de qualquer ID enviado pelo navegador. Não calcula o próximo ID com a quantidade de itens, portanto excluir um jogo não faz reutilizar seu ID durante a mesma execução.

Todas as operações sobre a lista e o contador são protegidas por `lock`. As consultas devolvem cópias dos objetos, evitando que alguém altere os registros armazenados fora dessa proteção. A atualização substitui o jogo do ID encontrado; ela nunca cadastra outro jogo quando o registro não existe.

Os jogos são compartilhados entre os visitantes dessa instância. Reiniciar o processo apaga a lista e reinicia o contador. Isso é o comportamento esperado para este checkpoint. Não há persistência externa dos jogos.

## Pesquisa, edição e exclusão

`Index(string? nome)` repassa o texto ao serviço. A pesquisa remove espaços das extremidades e procura o trecho no nome com `OrdinalIgnoreCase`, ignorando maiúsculas e minúsculas. Pesquisa vazia retorna todos os jogos. Sem correspondências, a View mostra “Nenhum jogo encontrado”. A busca não remove acentos.

No POST de edição, o ID da URL é obtido explicitamente com `[FromRoute]` e comparado ao ID do campo oculto. IDs diferentes ou registros inexistentes retornam 404. Depois da validação, o serviço atualiza as informações conservando o identificador.

O GET de exclusão apenas consulta o registro e apresenta a confirmação. O link Cancelar volta à biblioteca sem alterar a lista. Somente o POST chama `Excluir`. O método C# se chama `DeleteConfirmed`, mas `[ActionName("Delete")]` faz com que o formulário envie para `/Jogos/Delete/{id}`. O ID da rota determina o registro excluído.

Os três POSTs possuem `[ValidateAntiForgeryToken]`. Os formulários Razor já geram o campo oculto e o cookie de proteção. Requisições sem um token válido são rejeitadas antes da ação.

## Rotas disponíveis

- `GET /` ou `GET /Jogos` ou `GET /Jogos/Index`: biblioteca.
- `GET /Jogos?nome=texto`: pesquisa por nome.
- `GET /Jogos/Create`: formulário de cadastro.
- `POST /Jogos/Create`: valida e cadastra.
- `GET /Jogos/Details/{id}`: detalhes, ou 404.
- `GET /Jogos/Edit/{id}`: formulário preenchido, ou 404.
- `POST /Jogos/Edit/{id}`: valida e atualiza, ou 404 se o ID não corresponder/existir.
- `GET /Jogos/Delete/{id}`: confirmação, ou 404.
- `POST /Jogos/Delete/{id}`: exclusão confirmada, ou 404.
- `GET /Home/Index`: redireciona para a biblioteca.
- `GET /Home/Privacy` e `GET /Home/Error`: ações existentes preservadas.

Essas são rotas MVC que retornam páginas ou redirecionamentos, não uma API JSON.

## Executar e validar

Na raiz do projeto:

```powershell
dotnet restore
dotnet build
dotnet run --launch-profile http
```

O perfil HTTP original abre em `http://localhost:5099`. Se o executável estiver aberto pelo Visual Studio ou por outra execução, encerre essa execução antes de recompilar no mesmo diretório de saída.

Nesta sessão já havia outra instância bloqueando `bin/Debug/net10.0/ApiJogosMVC.exe`. A compilação padrão foi tentada e falhou por esse bloqueio. Foi utilizada uma saída independente para compilar e executar a versão nova sem interromper a instância anterior:

```powershell
dotnet build ApiJogosMVC.csproj --output bin/validacao
$env:ASPNETCORE_ENVIRONMENT = 'Development'
dotnet bin/validacao/ApiJogosMVC.dll --urls http://localhost:5100
```

A versão efetivamente validada está em `http://localhost:5100`. Uma aba antiga em `https://localhost:7218` pode continuar exibindo a instância anterior até ela ser encerrada, recompilada e reiniciada.

Com a aplicação de teste em execução, em outro terminal:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Validar-Crud.ps1
```

Para outra porta, acrescente `-BaseUrl http://localhost:5099`. O roteiro cria somente registros com nome de teste exclusivo e os exclui ao terminar; não exige uma biblioteca vazia.

## Verificações realmente executadas

- `dotnet restore`: passou.
- `dotnet build`: executado, encontrou o executável bloqueado por outra instância.
- `dotnet build ApiJogosMVC.csproj --output bin/validacao`: passou com zero erros e zero avisos.
- 34 verificações HTTP do roteiro: passaram. Cobrem CRUD, pesquisa, preço com centavos, edição sem duplicação, dados inválidos, campos omitidos, POST sem antiforgery, ID adulterado, IDs inexistentes/inválidos e repetição da exclusão.
- No navegador: biblioteca inicialmente vazia; formulário vazio com quatro mensagens em português; cadastro de Hollow Knight; listagem e detalhes; edição para Hollow Knight Editado, gênero Ação e R$ 79,99; busca `hOLLow`; busca sem resultados; abertura da confirmação; cancelamento preservando o registro; confirmação removendo o registro e retorno à biblioteca vazia.
- O acesso a ID inexistente foi confirmado como HTTP 404 no roteiro. A tentativa de navegação do navegador foi bloqueada pelo cliente (`ERR_BLOCKED_BY_CLIENT`), portanto a aparência da página de 404 não foi validada visualmente.
- A aplicação compilou e executou sem banco de dados ou dependências adicionais no arquivo de projeto. O singleton começa com a lista vazia a cada processo.

Os testes verificam o ambiente local. Não foi realizado teste de carga, de implantação ou de múltiplas instâncias; não fazem parte deste checkpoint.