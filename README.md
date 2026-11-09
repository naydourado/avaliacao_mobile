# Sweets by Isa

Aplicativo de vendas de doces feito em Flutter para a avaliação de PPDM do SENAI.

O cliente pode consultar o cardápio, pesquisar por nome ou categoria, salvar favoritos e fazer pedidos. A administradora pode cadastrar, editar e excluir produtos, além de acompanhar os pedidos e atualizar o status.

O projeto usa Flutter e Dart no aplicativo, Python com FastAPI no backend e SQLite no banco de dados. Favoritos e códigos dos pedidos ficam salvos no dispositivo com `shared_preferences`. A consulta de feriados usa a BrasilAPI.

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
.\.venv\Scripts\python.exe -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
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

- A API roda localmente. No Chrome, o aplicativo usa `http://127.0.0.1:8000`.
- No emulador Android, use `--dart-define=API_URL=http://10.0.2.2:8000`. A configuração nativa do Android ainda precisa ser concluída antes de gerar o APK.
- O acesso de cliente é compartilhado para demonstração. Os históricos de compras do cliente e da administradora ficam separados no dispositivo.
- O pagamento é combinado por Pix ou dinheiro na retirada. O aplicativo não processa pagamentos.
- A retirada é na faculdade, a combinar. A consulta de feriados não agenda a retirada.
- As fotos são ilustrativas e podem ser trocadas na pasta `assets/images/`.

O código foi organizado com base nos exemplos do [FlutterClass](https://github.com/naydourado/FlutterClass).
