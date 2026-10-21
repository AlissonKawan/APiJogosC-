# GameVault — Catálogo de Jogos

**Checkpoint 2 | ASP.NET Core MVC | FIAP — Análise e Desenvolvimento de Sistemas**  
**Professor:** Dr. Marcel Stefan Wagner  
**Nome do projeto:** GameVault  
**Tema do grupo:** Catálogo de Jogos

## Integrantes

| Nome | RM |
|---|---|
| Alisson Kawan Evangelista Silva | 567598 |
| Eduardo Boni | 567236 |
| Marcos Vinicius | 567214 |
| Kenji Fernandez | 568156 |

**Total de integrantes:** 4.

---

## 1. Visão geral

O **GameVault** é uma aplicação web desenvolvida em **C# com ASP.NET Core MVC** para gerenciar uma coleção de jogos pelo navegador. O usuário pode cadastrar jogos, consultar a coleção, pesquisar pelo nome, visualizar os detalhes de um registro, editar suas informações e excluí-lo após confirmar a operação.

O projeto foi criado para atender aos requisitos do Checkpoint 2 de ASP.NET Core MVC. A aplicação utiliza **Razor Views** para gerar o HTML, **Controllers** para receber as requisições e coordenar as ações, **Models** para representar e validar os dados e um **Service** para concentrar as regras de gerenciamento.

**Importante:** o projeto não usa banco de dados. Os jogos são mantidos em uma lista em memória enquanto a aplicação está em execução. O nome do repositório contém “API”, mas a interface entregue é uma aplicação **MVC com páginas HTML**, não uma API REST que responde em JSON.

## 2. Objetivos e funcionalidades

| Funcionalidade | Descrição |
|---|---|
| Cadastro (Create) | Formulário para adicionar um jogo com nome, gênero, preço e data de lançamento. |
| Listagem (Read) | Exibição dos jogos cadastrados em uma biblioteca com suas informações principais. |
| Detalhes (Read) | Visualização das informações de um jogo específico. |
| Edição (Update) | Alteração dos dados de um jogo existente, preservando seu identificador. |
| Exclusão (Delete) | Tela de confirmação antes de remover definitivamente o registro da memória. |
| Pesquisa | Filtro pelo nome do jogo, aceitando trechos do nome e ignorando diferenças entre maiúsculas e minúsculas. |
| Validação | Verificação dos dados dos formulários e apresentação de mensagens de erro em português. |
| Layout | Interface personalizada e compartilhada entre as páginas do projeto. |
| Tag Helpers | Uso de Tag Helpers nativos do ASP.NET Core MVC e de um Tag Helper próprio para exibir preços em reais. |

### 2.1. Regras de funcionamento

- O cadastro exige nome, preço válido, data de lançamento e gênero selecionado.
- O nome pode ter até 120 caracteres.
- O preço deve ser maior ou igual a **R$ 0,01**.
- O gênero é escolhido em uma lista baseada em `GeneroEnum`.
- Os IDs são gerados automaticamente pelo serviço e não podem ser escolhidos pelo usuário no cadastro.
- O sistema apresenta uma confirmação antes de excluir um jogo.
- Um identificador inexistente nas ações de detalhes, edição ou exclusão resulta em resposta HTTP **404**.
- A pesquisa sem texto retorna todos os jogos, e a pesquisa sem correspondências apresenta um estado vazio apropriado.
- Os dados **não permanecem salvos após reiniciar a aplicação**, por decisão de escopo do checkpoint.

## 3. Tecnologias e ferramentas

| Tecnologia | Uso no projeto |
|---|---|
| **C#** | Linguagem utilizada na implementação. |
| **.NET 10 / ASP.NET Core MVC** | Plataforma web, roteamento, controllers, binding e validação dos modelos. |
| **Razor (.cshtml)** | Construção das interfaces HTML com integração aos dados do servidor. |
| **HTML e CSS** | Estrutura e aparência das páginas. |
| **Bootstrap** | Estilos e recursos de interface incluídos no projeto. |
| **JavaScript / jQuery Validation** | Recursos de validação no navegador. |
| **Tag Helpers** | Geração de formulários, links, validação e formatação de preço. |
| **Injeção de dependência** | Compartilhamento de uma instância do serviço de jogos entre requisições. |
| **PowerShell** | Roteiro de verificações HTTP do CRUD. |
| **Visual Studio 2026** | Ambiente recomendado para abrir o projeto em .NET 10. |

**Dependências:** o arquivo `ApiJogosMVC.csproj` usa `Microsoft.NET.Sdk.Web`, com `TargetFramework` configurado como `net10.0`. Não há pacotes NuGet de terceiros declarados nesse arquivo; os recursos MVC são fornecidos pelo framework. Os arquivos estáticos de Bootstrap, jQuery e validação estão em `wwwroot/lib`.

**Padrões e recursos utilizados:** MVC, Service, injeção de dependência, DataAnnotations, Razor partial view, Post/Redirect/Get e validação de token antifalsificação (antiforgery).

## 4. Arquitetura e organização do projeto

### 4.1. Estrutura dos arquivos principais

~~~text
ApiJogosMVC/
├── ApiJogosMVC.slnx
├── ApiJogosMVC.csproj
├── Program.cs
├── Controllers/
│   ├── HomeController.cs
│   └── JogosController.cs
├── Models/
│   ├── ErrorViewModel.cs
│   ├── GeneroEnum.cs
│   └── JogoModel.cs
├── Services/
│   └── JogoService.cs
├── TagHelpers/
│   └── PrecoTagHelper.cs
├── Views/
│   ├── Home/
│   ├── Jogos/
│   │   ├── Index.cshtml
│   │   ├── Create.cshtml
│   │   ├── Edit.cshtml
│   │   ├── Details.cshtml
│   │   ├── Delete.cshtml
│   │   └── _JogoForm.cshtml
│   ├── Shared/
│   │   ├── _Layout.cshtml
│   │   └── _ValidationScriptsPartial.cshtml
│   ├── _ViewImports.cshtml
│   └── _ViewStart.cshtml
├── scripts/
│   └── Validar-Crud.ps1
├── wwwroot/
│   ├── css/site.css
│   ├── js/site.js
│   └── lib/
└── INTEGRACAO-VIEWS.md
~~~

### 4.2. Responsabilidades das camadas

**Model — `Models/JogoModel.cs`:** representa as propriedades de um jogo e define suas validações por meio de atributos `DataAnnotations`.

**View — `Views/Jogos/*.cshtml`:** mostra os dados e formulários no navegador. O arquivo `_Layout.cshtml` concentra a estrutura compartilhada (menu, conteúdo e rodapé), enquanto `_JogoForm.cshtml` reaproveita os mesmos campos nas telas de criação e edição.

**Controller — `Controllers/JogosController.cs`:** recebe as requisições HTTP, executa o model binding, verifica o `ModelState`, aciona o serviço e escolhe retornar uma View, um redirecionamento ou um erro HTTP.

**Service — `Services/JogoService.cs`:** administra a coleção de jogos, gera IDs e realiza as operações de inclusão, listagem, pesquisa, atualização, exclusão e consulta por identificador.

**Configuração — `Program.cs`:** registra os serviços na injeção de dependência, configura MVC, idioma/mensagens e define a rota padrão.

### 4.3. Diagrama do fluxo MVC

~~~mermaid
flowchart TD
    A["Usuário no navegador"] -->|"Requisição HTTP"| B["JogosController"]
    B -->|"Consulta ou operação"| C["JogoService"]
    C <--> D[("List de JogoModel em memória")]
    C -->|"Resultado"| B
    B -->|"Model enviado à View"| E["Razor View"]
    E -->|"HTML gerado"| A
~~~

### 4.4. Diagrama das classes principais

~~~mermaid
classDiagram
    class JogosController {
        -JogoService _jogos
        +Index(nome)
        +Create()
        +Create(jogo)
        +Details(id)
        +Edit(id)
        +Edit(id, jogo)
        +Delete(id)
        +DeleteConfirmed(id)
    }

    class JogoService {
        -List~JogoModel~ _jogos
        -int _proximoId
        +Listar(nome)
        +BuscarPorId(id)
        +Cadastrar(jogo)
        +Atualizar(id, jogo)
        +Excluir(id)
    }

    class JogoModel {
        +int Id
        +string Nome
        +decimal Preco
        +DateTime DataLancamento
        +GeneroEnum Genero
    }

    class GeneroEnum {
        <<enumeration>>
        NaoSelecionado
        Acao
        Aventura
        RPG
        Esporte
        Estrategia
        Simulacao
        Corrida
        Luta
        Terror
    }

    JogosController --> JogoService : utiliza
    JogoService "1" o-- "*" JogoModel : gerencia
    JogoModel --> GeneroEnum : utiliza
~~~

## 5. Modelagem dos dados

A classe `JogoModel` contém as seguintes propriedades:

| Propriedade | Tipo C# | Finalidade | Validação |
|---|---|---|---|
| `Id` | `int` | Identificador do registro. | Gerado automaticamente no serviço. |
| `Nome` | `string` | Nome do jogo. | Obrigatório; máximo de 120 caracteres. |
| `Preco` | `decimal` | Preço do jogo. | Obrigatório no formulário; mínimo de 0,01. |
| `DataLancamento` | `DateTime` | Data de lançamento. | Obrigatória no formulário. |
| `Genero` | `GeneroEnum` | Categoria do jogo. | Deve representar um valor válido, diferente de “não selecionado”. |

O enum `GeneroEnum` oferece as opções Ação, Aventura, RPG, Esporte, Estratégia, Simulação, Corrida, Luta e Terror, além de uma opção inicial inválida para obrigar a seleção.

**Validação:** o ASP.NET Core combina model binding e atributos como `[Required]`, `[StringLength]`, `[Range]`, `[EnumDataType]` e `[BindRequired]`. A ação POST consulta `ModelState.IsValid` antes de alterar os dados. Caso os valores sejam inválidos, o usuário retorna ao formulário com as mensagens de erro correspondentes.

## 6. Rotas e operações HTTP

As rotas abaixo são **endpoints MVC**: elas renderizam páginas, processam formulários ou redirecionam o navegador.

| Método | Rota | Operação |
|---|---|---|
| `GET` | `/` | Abre a biblioteca, por meio da rota padrão. |
| `GET` | `/Jogos` ou `/Jogos/Index` | Lista os jogos cadastrados. |
| `GET` | `/Jogos?nome=texto` | Pesquisa jogos pelo nome. |
| `GET` | `/Jogos/Create` | Abre o formulário de cadastro. |
| `POST` | `/Jogos/Create` | Valida e cadastra um jogo. |
| `GET` | `/Jogos/Details/{id}` | Apresenta os detalhes de um jogo. |
| `GET` | `/Jogos/Edit/{id}` | Abre o formulário de edição preenchido. |
| `POST` | `/Jogos/Edit/{id}` | Valida e atualiza um jogo. |
| `GET` | `/Jogos/Delete/{id}` | Exibe a confirmação de exclusão. |
| `POST` | `/Jogos/Delete/{id}` | Confirma e realiza a exclusão. |

Também existe `GET /Home/Index`, que redireciona à biblioteca.

### 6.1. Exemplo de fluxo de cadastro

1. O usuário acessa `GET /Jogos/Create`.
2. O Controller retorna `Views/Jogos/Create.cshtml` com os campos do formulário.
3. Ao enviar, o navegador realiza `POST /Jogos/Create`.
4. O ASP.NET Core vincula os campos às propriedades de `JogoModel` e executa a validação.
5. Se houver erro, o Controller devolve a mesma View com mensagens de validação.
6. Se os dados forem válidos, o Controller chama `JogoService.Cadastrar`.
7. O Service gera um novo ID e adiciona o jogo à lista em memória.
8. O Controller redireciona para `Index`, e o navegador exibe a coleção atualizada.

O redirecionamento após o POST segue o padrão **Post/Redirect/Get**, evitando reenviar acidentalmente o formulário quando a página da listagem é atualizada.

### 6.2. Edição e exclusão

Na edição, o ID da rota é comparado ao ID do modelo enviado no formulário. A operação só é aplicada a um registro existente e válido.

Na exclusão, a requisição GET **não exclui** o jogo: ela apenas apresenta a tela de confirmação. A exclusão acontece somente após o envio do formulário por POST. O botão de cancelamento mantém o registro na biblioteca.

## 7. Tag Helpers utilizados

O projeto usa os Tag Helpers fornecidos pelo ASP.NET Core MVC:

- `asp-controller` e `asp-action`: geram URLs de navegação e de envio dos formulários;
- `asp-route-id`: inclui o identificador do jogo na rota;
- `asp-for`: conecta o campo HTML a uma propriedade do Model;
- `asp-items`: preenche as opções do seletor de gênero;
- `asp-validation-for` e `asp-validation-summary`: exibem os erros de validação;
- `asp-antiforgery`: insere os dados de proteção contra falsificação de requisições;
- `asp-append-version`: auxilia no versionamento do arquivo CSS.

Além disso, o arquivo `TagHelpers/PrecoTagHelper.cs` contém um **Tag Helper personalizado** registrado em `Views/_ViewImports.cshtml`. Ele recebe um valor decimal, converte-o para a moeda brasileira e produz um elemento HTML `span`.

Exemplo de uso em uma View:

~~~cshtml
<preco valor="@jogo.Preco" />
~~~

Para um preço de `49.90`, a saída visual é **R$ 49,90**.

## 8. Interface e telas

A aplicação possui identidade visual própria, denominada **GameVault**, e organiza a navegação a partir de um layout compartilhado. O CSS personalizado está em `wwwroot/css/site.css`.

| Tela | View | Finalidade |
|---|---|---|
| Biblioteca | `Views/Jogos/Index.cshtml` | Tela inicial, listagem, pesquisa e acesso às ações dos jogos. |
| Adicionar jogo | `Views/Jogos/Create.cshtml` | Cadastro com campos e validações. |
| Detalhes | `Views/Jogos/Details.cshtml` | Consulta completa de um jogo selecionado. |
| Editar jogo | `Views/Jogos/Edit.cshtml` | Alteração de informações existentes. |
| Excluir jogo | `Views/Jogos/Delete.cshtml` | Revisão dos dados e confirmação explícita antes da remoção. |

**Evidências visuais:** os prints e as explicações ilustradas das telas serão organizados em **um documento complementar separado** do README, a ser entregue pelo grupo. Este README documenta a implementação e o funcionamento; o documento visual deverá conter capturas reais do sistema em execução, incluindo as operações de CRUD, a pesquisa e a confirmação de exclusão.

## 9. Persistência em memória e injeção de dependências

O `JogoService` guarda os registros em uma `List<JogoModel>` privada e mantém um contador para gerar identificadores. Em `Program.cs`, ele é registrado com:

~~~csharp
builder.Services.AddSingleton<JogoService>();
~~~

Esse ciclo de vida mantém **uma instância do serviço por processo de aplicação**, permitindo que as requisições sucessivas compartilhem a mesma lista enquanto o processo estiver em execução.

Para proteger a lista e o contador de acessos simultâneos, as operações do serviço utilizam `lock`. Os métodos de consulta retornam cópias dos modelos, evitando alterações externas à coleção armazenada.

**Limitações esperadas do escopo:**

- Os registros são perdidos quando o processo é encerrado ou reiniciado.
- A aplicação não utiliza SQL, Entity Framework Core nem outro mecanismo de persistência.
- Não existe autenticação ou separação de bibliotecas por usuário.
- O filtro de nome ignora maiúsculas/minúsculas, mas não normaliza acentos.

## 10. Segurança, tratamento de erros e validações

- As ações POST de criação, edição e exclusão usam `[ValidateAntiForgeryToken]`.
- O servidor verifica `ModelState.IsValid` antes de cadastrar ou editar.
- As entradas incorretas retornam mensagens explicativas para os campos do formulário.
- Os IDs inexistentes ou inválidos são tratados por respostas HTTP **404 (Not Found)**.
- A atualização valida a coerência entre o identificador da URL e o enviado no formulário.
- A exclusão exige confirmação em uma tela específica.
- A apresentação de preços utiliza `pt-BR`; o binding numérico foi configurado com cultura `en-US` para interpretar corretamente valores de formulários HTML com ponto decimal.

## 11. Como executar o projeto

### 11.1. Pré-requisitos

- **Windows** com **Visual Studio 2026**, incluindo suporte a desenvolvimento ASP.NET e Web;
- **.NET 10 SDK** instalado;
- Navegador de internet;
- **PowerShell**, caso deseje executar o roteiro de verificações HTTP.

### 11.2. Pelo Visual Studio

1. Clone ou baixe o repositório.
2. Abra `ApiJogosMVC.slnx` no **Visual Studio 2026**.
3. Aguarde a restauração das dependências.
4. Configure `ApiJogosMVC` como projeto de inicialização, se necessário.
5. Execute a aplicação com `F5` ou `Ctrl+F5`.
6. Acesse o endereço local exibido pelo Visual Studio e navegue pela biblioteca.

### 11.3. Pelo terminal

Na raiz do repositório:

~~~powershell
dotnet restore
dotnet build
dotnet run --launch-profile http
~~~

O perfil HTTP disponível em `Properties/launchSettings.json` utiliza `http://localhost:5099`, salvo se as configurações locais forem modificadas.

### 11.4. Gerar Debug e Release para a entrega

~~~powershell
dotnet build -c Debug
dotnet build -c Release
~~~

As saídas de compilação são geradas em `bin/Debug/net10.0/` e `bin/Release/net10.0/`. As pastas `bin/` e `obj/` estão ignoradas no Git, mas **o arquivo compactado entregue ao professor precisa conter as pastas Debug e Release**, conforme o enunciado.

## 12. Testes e verificações

### 12.1. Roteiro automatizado de verificações HTTP

O repositório contém `scripts/Validar-Crud.ps1`, que executa verificações sobre a aplicação em funcionamento. Entre os cenários cobertos pelo roteiro estão:

- Acesso à biblioteca e busca sem resultados;
- Rejeição de campos vazios, omitidos ou inválidos;
- Rejeição de preço zero, preço negativo e dados incompatíveis;
- Cadastro válido e geração de ID;
- Exibição do preço com centavos;
- Consulta de detalhes;
- Edição válida e inválida, sem duplicar registros;
- Pesquisa sem diferenciação entre letras maiúsculas e minúsculas;
- Abertura da confirmação de exclusão sem apagar o jogo;
- Exclusão efetivada somente por POST;
- Bloqueio de requisições POST sem token antiforgery;
- Resposta 404 para registros inexistentes e IDs inválidos.

O arquivo [`INTEGRACAO-VIEWS.md`](INTEGRACAO-VIEWS.md) registra a execução de **34 verificações HTTP concluídas com sucesso** no ambiente de desenvolvimento usado durante a implementação. Esse resultado está documentado no repositório e pode ser reproduzido localmente; não representa teste de implantação em produção.

Para executar, mantenha o site iniciado e abra outro terminal PowerShell na raiz do projeto:

~~~powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Validar-Crud.ps1 -BaseUrl http://localhost:5099
~~~

### 12.2. Roteiro de testes manuais no navegador

| Teste | Ação | Resultado esperado |
|---|---|---|
| Listagem vazia | Abrir a aplicação antes de cadastrar jogos. | Mensagem orientando o primeiro cadastro. |
| Cadastro inválido | Enviar formulário com campos obrigatórios vazios. | Mensagens de validação; jogo não cadastrado. |
| Cadastro válido | Preencher nome, gênero, preço e data válidos. | Retorno à biblioteca com o novo jogo. |
| Detalhes | Clicar em “Detalhes” de um jogo cadastrado. | Exibição das informações completas. |
| Pesquisa | Buscar por parte do nome de um jogo. | Exibição dos registros correspondentes. |
| Edição | Alterar o nome ou preço de um jogo. | Dados atualizados no mesmo registro. |
| Cancelar exclusão | Entrar em “Excluir” e clicar em “Cancelar”. | Registro permanece na lista. |
| Confirmar exclusão | Entrar em “Excluir” e confirmar. | Registro removido da coleção. |
| Reinício | Reiniciar a aplicação. | Lista em memória volta ao estado inicial. |

## 13. Entrega do Checkpoint 2

**Prazo definido pelo professor: 25/10/2026 às 23h59.**

O enunciado solicita que um único integrante envie a entrega **pelo chat direto do professor no Teams**, não pelo chat geral da disciplina.

Materiais de entrega:

1. Arquivo `.zip`, `.rar` ou `.7z` com a pasta completa do projeto, incluindo solução, subpastas e saídas **Debug** e **Release**.
2. Arquivo `.txt` contendo o link do GitHub: [AlissonKawan/APiJogosC-](https://github.com/AlissonKawan/APiJogosC-).
3. README com dados da equipe, descrição, arquitetura, diagramas, funcionalidades, rotas, testes e instruções de execução.
4. **Documento complementar de evidências visuais**, organizado separadamente pelo grupo, com prints reais e explicações sobre as telas.

> **Observação sobre a rubrica:** o enunciado original pede expressamente os prints *no README*. O grupo optou por organizá-los em um documento separado; antes de enviar, é recomendável confirmar se o professor aceita esse formato ou acrescentar no README referências às evidências.

O professor também exige que o tema tenha sido comunicado no chat geral da disciplina até **16/10/2026**, juntamente com os integrantes e RMs, e que não seja um tema já utilizado por outro grupo.

## 14. Referências internas do projeto

- [Controller de jogos](Controllers/JogosController.cs)
- [Model de jogos](Models/JogoModel.cs)
- [Enum de gêneros](Models/GeneroEnum.cs)
- [Serviço de jogos](Services/JogoService.cs)
- [Tag Helper de preço](TagHelpers/PrecoTagHelper.cs)
- [Views da biblioteca](Views/Jogos)
- [Roteiro de testes HTTP](scripts/Validar-Crud.ps1)
- [Explicação técnica detalhada do back-end](INTEGRACAO-VIEWS.md)

---

**GameVault** — Projeto acadêmico desenvolvido para o Checkpoint 2 de ASP.NET Core MVC da FIAP.
