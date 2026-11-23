# Sweets by Isa

Aplicativo de vendas de doces feito em Flutter para a avaliação de PPDM do SENAI.

O cliente pode consultar o cardápio, pesquisar por nome ou categoria, salvar favoritos e fazer pedidos. A administradora pode cadastrar, editar e excluir produtos, além de acompanhar os pedidos e atualizar o status.

O projeto usa Flutter e Dart no aplicativo, Python com FastAPI no backend e SQLite no banco de dados. Favoritos e códigos dos pedidos ficam salvos no dispositivo com `shared_preferences`. A consulta de feriados usa a BrasilAPI.

## Requisitos e componentes

| Requisito do cliente | Tela / componente |
| --- | --- |
| Apresentar o cardápio | `TelaHome`, `GradeProdutos`, `ProdutoCard` |
| Entrar como cliente ou administradora | `TelaLogin`, `AutenticacaoService` |
| Salvar favoritos | `TelaFavoritos`, `shared_preferences` |
| Fazer pedido | `TelaCarrinho`, `PedidoService` (POST) |
| Acompanhar pedido | `TelaPedidos`, `PedidoCard` (GET) |
| Cadastrar, editar e excluir produtos | `TelaGestao`, `ProdutoService` (POST, PUT, DELETE) |
| Atualizar status do pedido | `TelaGestaoPedidos` (PUT) |
| Consultar feriados | `TelaFeriados`, `FeriadoService` (BrasilAPI) |

Dados públicos (produtos e pedidos) ficam no banco externo, acessado pela API. Dados do usuário (favoritos e códigos dos pedidos) ficam só no dispositivo.

## Características do Dart usadas

- **Null safety:** `String? erro` só aceita nulo porque tem `?`; em Java qualquer objeto pode ser nulo.
- **Parâmetros nomeados:** `Produto(id: 1, nome: 'Brownie', ...)` com `required`, em vez da ordem fixa do Java.
- **Construtor `factory`:** `Produto.fromJson` devolve a subclasse certa (`Brownie`, `Cookie`, `PalhaItaliana`).
- **`if` dentro de listas:** a `NavBar` mostra a aba Admin ou Favoritos com `if (administrador) ... else ...` direto na lista de telas.

## Como rodar

É necessário ter Flutter 3.35 ou superior e Python instalado. Para conferir o ambiente:

```powershell
flutter doctor
py --version
```

Na pasta do projeto, abra um terminal para iniciar a API:

```powershell
cd backend
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
$env:ADMIN_KEY = "senha-admin"
$env:CLIENT_PASSWORD = "senha-cliente"
.\.venv\Scripts\python.exe -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

A documentação da API fica em http://127.0.0.1:8000/docs. O banco é criado em `backend/sweets.db`.

Em outro terminal, na raiz do projeto:

```powershell
flutter pub get
flutter run -d chrome
```

Mantenha o terminal da API aberto enquanto usa o aplicativo.

## Acesso

| Perfil | Usuário | Senha do exemplo |
| --- | --- | --- |
| Cliente | `cliente` | `senha-cliente` |
| Administradora | `admin` | `senha-admin` |

As senhas são definidas nas variáveis `CLIENT_PASSWORD` e `ADMIN_KEY`, no terminal da API. A aba Admin aparece apenas para a administradora.

## Testes

Na raiz do projeto:

```powershell
flutter analyze
flutter test
```

Para testar o backend:

```powershell
cd backend
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -q
```

## Observações

- O aplicativo acessa a API em `http://10.109.72.20:8000` (IP do PC na rede da escola). Em outra rede, troque o endereço em `lib/services/produto_service.dart` e gere o APK de novo.
- O APK está em `apk/sweets_by_isa.apk`. Para gerar: `flutter build apk`, arquivo em `build/app/outputs/flutter-apk/app-release.apk`.
- O acesso de cliente é compartilhado para demonstração. Os históricos de compras do cliente e da administradora ficam separados no dispositivo.
- O pagamento é combinado por Pix ou dinheiro na retirada. O aplicativo não processa pagamentos.
- A retirada é na faculdade, a combinar. A consulta de feriados não agenda a retirada.
- As fotos são ilustrativas e podem ser trocadas na pasta `assets/images/`.

O código foi organizado com base nos exemplos do [FlutterClass](https://github.com/naydourado/FlutterClass).