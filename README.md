# Sweets by Isa — Flutter • Etapa 5 (navegação por perfil e painel administrativo)

Projeto de avaliação PPDM para a loja Sweets by Isa. Código organizado de forma simples, inspirado no `mercadinho_app` do [FlutterClass](https://github.com/naydourado/FlutterClass): `StatefulWidget`, `setState`, `Navigator`, `ListView`, classes e HTTP com JSON.

## Login de cliente e administradora (mantido da Etapa 4)

O aplicativo começa em uma tela de login com **Usuário** e **Senha**. O backend valida as credenciais na rota `POST /login` e responde com o perfil `CLIENTE` ou `ADMIN`. Na Etapa 5, a navegação inferior e a área administrativa foram reorganizadas, sem alterar o backend.

| Perfil | Usuário | Senha | Pode acessar |
| --- | --- | --- | --- |
| Cliente | `cliente` | Definida em `CLIENT_PASSWORD` no terminal da API | Cardápio, favoritos, carrinho e acompanhamento de pedidos |
| Administradora | `admin` | Definida em `ADMIN_KEY` no terminal da API | Cardápio, carrinho, seus pedidos e **painel Admin** (no lugar de Favoritos) |

- Os campos são verificados pela API; dados inválidos mostram mensagem de erro.
- **Sair** volta ao login e elimina a senha administrativa da memória do app.
- A aba Admin (engrenagem) aparece só para o perfil `ADMIN`; a própria API também bloqueia o GET administrativo, POST, PUT e DELETE sem a chave válida.
- Não existe cadastro de vários clientes: `cliente` é uma **conta compartilhada de demonstração**, não uma conta pessoal. Não use para pedidos reais ou dados sensíveis.
- As senhas **não ficam gravadas em SharedPreferences nem no código Flutter**. Este protótipo trafega dados via HTTP **somente na máquina de desenvolvimento**. Para uso real, seriam necessários HTTPS e autenticação/sessões adequadas.

## Funcionalidades preservadas das Etapas 1 a 3

- **Cardápio**: GET da API própria com Brownie R$ 12, Cookie tradicional R$ 12, Cookie recheado R$ 14 e Palha italiana R$ 12.
- **Gestão de produtos**: em **Admin → Gerenciar produtos**, criar (POST), consultar (GET), editar (PUT) e excluir (DELETE) no banco SQLite. As operações de escrita exigem chave administrativa validada no login.
- **Carrinho e pedido de verdade**: preencher nome, Pix/dinheiro, observações e tocar em **Confirmar pedido**. A API cria o pedido e devolve um código aleatório. **O valor final é calculado no servidor**, nunca confiando no total enviado pelo aplicativo.
- **Meus pedidos**: os códigos ficam armazenados localmente no dispositivo (`shared_preferences`); GET por código consulta o pedido e seu status. O código também pode ser digitado manualmente.
- **Gestão de pedidos**: no perfil administradora, abra a aba **Admin** (ícone de engrenagem) e toque em **Gerenciar pedidos**. Consulte os pedidos e altere o status (PUT): Recebido, Em preparo, Pronto para retirada, Entregue, Cancelado.
- **Segunda API**: ícone de calendário na barra superior abre a consulta à **BrasilAPI** de feriados nacionais e do estado de SP. Isso não agenda nem confirma uma retirada.
- **Persistência no dispositivo**: favoritos e códigos dos pedidos; **persistência na API**: produtos, pedidos e status no SQLite.
- **Classes e subclasses**: `Produto` e `Brownie`, `Cookie`, `PalhaItaliana`; `Pedido` e `ItemPedido` são classes para dados do backend.

**Limitações importantes:** é um protótipo acadêmico. A API roda localmente no seu computador (não fica disponível quando o servidor está desligado). Não processa pagamento, não confirma retirada automaticamente, não envia mensagens nem possui contas individuais ou sessões seguras. **Não use para aceitar encomendas reais nem publique a API de desenvolvimento na internet**, pois o acesso por chave é propositalmente básico. A segunda API depende de internet. O app não exige informar endereço ou telefone do cliente.

## Fluxo das telas — Etapa 5

A segunda aba da barra inferior é definida conforme o login:

| Perfil | Abas inferiores | Acesso à gestão |
| --- | --- | --- |
| Cliente (`cliente`) | Cardápio • **Favoritos** • Carrinho • Pedidos | Não possui |
| Administradora (`admin`) | Cardápio • **Admin ⚙️** • Carrinho • Meus pedidos | **Admin → Produtos / Pedidos recebidos** |

Dentro da aba **Admin**, há duas opções separadas:

1. **Gerenciar produtos:** abre a lista cadastrada, com botão **Novo doce** (POST), lápis para **editar** (PUT) e lixeira para **excluir** (DELETE, exige confirmação). A lista utiliza GET e sincroniza o cardápio após mudanças. A seta de voltar retorna ao painel Admin.
2. **Gerenciar pedidos:** abre a lista de pedidos recebidos (GET) com nome do cliente, itens, pagamento e total. A administradora escolhe o novo status na lista (PUT). A seta de voltar retorna ao painel Admin.

A engrenagem extra da barra superior foi removida, evitando dois caminhos para o mesmo lugar. No cardápio do perfil administrador também não aparece o botão de coração, já que esse perfil não possui aba de Favoritos.

O botão **Pedidos / Meus pedidos** na barra inferior é o acompanhamento de pedidos feitos no dispositivo; **Gerenciar pedidos**, dentro de Admin, lista os pedidos recebidos pela loja.

As rotas, o banco de dados e as credenciais são os mesmos da Etapa 4. Esta etapa reorganiza as telas sem mudar a API.

## 1. Atualizar o projeto já existente

1. Faça backup da pasta `SWEETS_BY_ISA` que você já tem.
2. Extraia `sweets_by_isa_etapa5.zip`.
3. **Entre na pasta `sweets_by_isa` extraída** e copie as pastas `lib`, `assets`, `backend`, `test`, `android` e o `pubspec.yaml`, `README.md` para dentro de sua pasta atual `SWEETS_BY_ISA`, aceitando mesclagem/substituição dos arquivos com o mesmo nome.
4. **Não apague** as pastas nativas que o Flutter criou, como `android` e `web`. Não precisa executar `flutter create` novamente.
5. Se você já testou a Etapa 2 e tem `backend/sweets.db`, **não exclua esse arquivo**. Ele não faz parte do ZIP e será preservado; a API criará as novas tabelas automaticamente.

## 2. Preparar ambiente do zero (critério da avaliação)

Instale Flutter SDK, VS Code, extensão Flutter e Dart, Android SDK/Android Studio, Python e Git. **Error Lens** é uma extensão opcional para mostrar erros em linha. Abra o PowerShell e valide:

```powershell
flutter doctor -v
flutter doctor --android-licenses
py --version
```

## 3. Terminal 1 — iniciar a API

Abra um PowerShell na pasta principal `SWEETS_BY_ISA`:

```powershell
cd backend
py -m pip install -r requirements.txt
$env:ADMIN_KEY = "minha-chave-admin-de-teste"
$env:CLIENT_PASSWORD = "senha-cliente-de-teste"
py -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

No Chrome, confira:

- http://127.0.0.1:8000/produtos — quatro produtos em JSON (ou os que você editou).
- http://127.0.0.1:8000/docs — documentação interativa das rotas (incluindo `/pedidos`).

Não coloque `ADMIN_KEY` nem `CLIENT_PASSWORD` no código-fonte nem envie as senhas ao GitHub. Esta chave só protege o ambiente de testes, não substitui autenticação em produção. O banco fica em `backend/sweets.db`.

## 4. Terminal 2 — iniciar o Flutter no Chrome

Abra **outro terminal**, na pasta `SWEETS_BY_ISA`:

```powershell
flutter pub get
flutter run -d chrome
```

Não feche o terminal da API. O endereço padrão da API é `http://127.0.0.1:8000` e funciona no Chrome **do mesmo computador**.

### Testar no emulador Android

No terminal da API: `Ctrl+C`, e reinicie com:

```powershell
$env:ADMIN_KEY = "minha-chave-admin-de-teste"
$env:CLIENT_PASSWORD = "senha-cliente-de-teste"
py -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Na raiz do projeto Flutter:

```powershell
flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:8000
```

`10.0.2.2` é o IP especial do emulador Android padrão para acessar o computador. O `android/app/src/debug/AndroidManifest.xml` permite HTTP local somente no modo debug. Em um celular físico seria necessário usar o IP da máquina na rede e configurar o firewall.

## 5. Testar os dois perfis

1. Com os terminais funcionando, entre como **cliente**, usuário `cliente`, senha `senha-cliente-de-teste`.
2. Confira que estão disponíveis **Cardápio, Favoritos, Carrinho e Pedidos**, mas **não** a engrenagem de administração.
3. Adicione 2 Brownies e 1 Cookie recheado: o total estimado deve ser R$ 38,00. Informe um nome de teste e finalize um pedido. Copie o código.
4. Clique em **Sair** (ícone de porta). Tente usuário `admin` com senha incorreta: a API deverá recusar o login.
5. Entre como **administradora**, usuário `admin`, senha `minha-chave-admin-de-teste` (ou a chave que você escolheu para `ADMIN_KEY`).
6. Confira que agora a **segunda aba é Admin (engrenagem)**, no lugar de Favoritos. Entre em **Admin → Gerenciar produtos** e teste cadastrar, editar e excluir um produto fictício.
7. Volte ao painel Admin e entre em **Admin → Gerenciar pedidos**. Altere o status do pedido de teste para **Em preparo**.
8. Saia e entre como cliente novamente. Em **Meus pedidos**, atualize e confira a mudança de status.
9. Toque no calendário para consultar a segunda API (feriados) e verificar a integração adicional.

**Observação:** os favoritos e códigos de pedidos continuam sendo salvos no dispositivo para a demonstração. Como há somente uma conta de cliente de teste, esses dados não representam um sistema de contas individuais.

## 6. Critérios de avaliação: evidência e situação

| Critério | Evidência no código | Situação |
| --- | --- | --- |
| Preparar o ambiente (crítico) | README §§2–4, `flutter doctor` | Documentação; comprovação na máquina do aluno |
| IDE e plugins (crítico) | Flutter/Dart; Error Lens opcional | Documentação; conferir instalação |
| Importar bibliotecas (desejável) | `pubspec.yaml`: `http`, `shared_preferences` | Código implementado |
| Interpretar os requisitos (crítico) | Telas cardápio, favoritos, carrinho, pedidos e gestão | Implementado em código |
| Definir variáveis, processos e saídas (crítico) | `Produto`, `Pedido`, formulários, total e status | Implementado em código |
| Interfaces: mínimo 3 telas (crítico) | `tela_login.dart`, `tela_home.dart`, `tela_carrinho.dart`, `tela_pedidos.dart`, `tela_admin.dart`, `tela_gestao.dart` | Implementado em código |
| Objetivo das interfaces (crítico) | Botões, rótulos, cards, mensagens e navegação | Implementado em código |
| Acessos cliente e gestão (adicional) | `tela_login.dart`, `autenticacao_service.dart`, `main.dart`, `navbar.dart`, `tela_admin.dart`, `backend/main.py` | Dois perfis via `POST /login`; abas por perfil |
| Responsividade (desejável) | `GridView`, `ListView`, widgets flexíveis | Implementação inicial; validar no dispositivo |
| Lógica Dart (crítico) | `if`, `for`, `setState`, `async/await` | Implementado em código |
| Comparar Dart a outra linguagem (desejável) | Comentário em `lib/models/produto.dart` (Dart vs. Python) | Implementado em código |
| Persistir cache local (crítico) | `shared_preferences` favoritos + códigos dos pedidos | Implementado em código |
| Persistir alterações locais (desejável) | Favoritar/desfavoritar e salvar lista dos códigos | Implementado em código |
| GET (crítico) | `ProdutoService.listarProdutos`, `PedidoService.consultarPedido` | Implementado e testado na API |
| POST (crítico) | `ProdutoService.criarProduto`, `PedidoService.criarPedido` | Implementado e testado na API |
| PUT (crítico) | `ProdutoService.editarProduto`, `PedidoService.atualizarStatus` | Implementado e testado na API |
| DELETE (crítico) | `ProdutoService.excluirProduto` com confirmação | Implementado e testado na API |
| Múltiplas APIs (desejável) | `PedidoService`/`ProdutoService` (API própria) + `FeriadoService` (BrasilAPI) | Código implementado; testar conexão na máquina |
| Classes (crítico) | `Produto`, `Pedido`, `PedidoService` | Implementado |
| Subclasses (crítico) | `Brownie`, `Cookie`, `PalhaItaliana` em `produto.dart` | Implementado |
| Componentização (desejável) | `components/produto_card.dart` | Implementado |
| Exportar APK e instalar (crítico) | Comandos abaixo | **Ainda não executado** |
| Competências socioemocionais | Histórico de tarefas, versões, pesquisas, testes e prazos | **Você deve apresentar evidências reais** |

## 7. Verificar código e testes

Na pasta `backend` com pytest e httpx disponíveis:

```powershell
py -m pip install pytest httpx
py -m pytest -q test_api.py test_pedidos.py test_login.py
```

Na pasta principal Flutter:

```powershell
flutter analyze
flutter test
```

O Flutter SDK não está disponível no ambiente de geração destes arquivos. **Você precisa executar `flutter analyze`, `flutter test` e testar visualmente no seu computador**. Os testes automatizados de backend foram executados com sucesso, incluindo login e bloqueio de acesso administrativo.

## 8. Gerar o APK (quando finalizar)

```powershell
flutter build apk --release
```

APK esperado em `build/app/outputs/flutter-apk/app-release.apk`. **Antes de instalar para uso real, precisamos hospedar a API com HTTPS, autenticação adequada e banco persistente**. O APK desta versão ainda apontará por padrão para uma API local e só alcançará o computador com configuração específica de rede.

## 9. Fotografias e dados reais

As imagens ainda são **ilustrativas** e podem ser substituídas mantendo os nomes em `assets/images/`. A retirada é **na faculdade, a combinar**, sem delivery. O app informa pagamento Pix/dinheiro, mas **não efetua pagamento**. Instagram: `@sweetsbyisa.ofc`.

### APIs

- API Sweets by Isa: FastAPI local, dados SQLite, rotas `/login`, `/produtos` e `/pedidos`.
- BrasilAPI: `GET https://brasilapi.com.br/api/feriados/v1/2026?uf=SP` (ano dinamicamente selecionado no app). Documentação: https://brasilapi.com.br/docs. O calendário traz feriados nacionais/estaduais, não necessariamente municipais ou eventos da faculdade.
