import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweets_by_isa/components/produto_card.dart';
import 'package:sweets_by_isa/models/produto.dart';
import 'package:sweets_by_isa/navigation/navbar.dart';
import 'package:sweets_by_isa/screens/tela_carrinho.dart';
import 'package:sweets_by_isa/screens/tela_feriados.dart';
import 'package:sweets_by_isa/screens/tela_home.dart';
import 'package:sweets_by_isa/screens/tela_login.dart';
import 'package:sweets_by_isa/services/feriado_service.dart';
import 'package:sweets_by_isa/services/pedido_service.dart';
import 'package:sweets_by_isa/services/produto_service.dart';
import 'package:sweets_by_isa/theme/app_theme.dart';
import 'fluxos_test.dart' show ApiDeTeste, tocar;

const gerarPrevias = bool.fromEnvironment('GERAR_PREVIAS');
const chavePrevia = Key('previa');

Future<void> abrirTela(
  WidgetTester tester,
  Widget tela,
  Size tamanho, {
  double escala = 1,
}) async {
  await tester.binding.setSurfaceSize(tamanho);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    RepaintBoundary(
      key: chavePrevia,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(size: tamanho, textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: tela,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> salvarPrevia(WidgetTester tester, String nome) async {
  if (!gerarPrevias) return;
  await tester.runAsync(() async {
    final contexto = tester.element(find.byKey(chavePrevia));
    for (final nome in [
      'brownie',
      'cookie_tradicional',
      'cookie_recheado',
      'palha_italiana',
    ]) {
      await precacheImage(AssetImage('assets/images/$nome.png'), contexto);
    }
  });
  await tester.pumpAndSettle();
  final limite = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(chavePrevia),
  );
  await tester.runAsync(() async {
    final imagem = await limite.toImage(pixelRatio: 1);
    final dados = await imagem.toByteData(format: ui.ImageByteFormat.png);
    final arquivo = File('build/previas/$nome.png');
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(dados!.buffer.asUint8List());
    imagem.dispose();
  });
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Fonte do sistema só para as imagens opcionais; os testes normais são portáveis.
    if (gerarPrevias && Platform.isWindows) {
      final fonte = FontLoader('Roboto');
      for (final nome in ['segoeui.ttf', 'segoeuib.ttf']) {
        fonte.addFont(
          Future.value(
            ByteData.sublistView(
              await File('C:/Windows/Fonts/$nome').readAsBytes(),
            ),
          ),
        );
      }
      await fonte.load();
      final icones = FontLoader('MaterialIcons');
      icones.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icones.load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final largura in [320.0, 390.0, 1280.0]) {
    testWidgets('Login permite entrar e rolar em $largura pixels', (
      tester,
    ) async {
      await abrirTela(
        tester,
        TelaLogin(onEntrar: (_, _) {}),
        Size(largura, 844),
      );
      await salvarPrevia(tester, 'login-${largura.toInt()}');
      await tocar(tester, find.text('Entrar'));
      expect(find.text('Preencha usuário e senha.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Feriados exibe DD-MM-AAAA em $largura pixels', (tester) async {
      final servico = FeriadoService(
        cliente: MockClient(
          (_) async => http.Response(
            '[{"date":"2026-01-01","name":"Confraternização universal"},'
            '{"date":"2026-11-15","name":"Proclamação da República"}]',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      await abrirTela(
        tester,
        TelaFeriados(servico: servico),
        Size(largura, 844),
      );
      await salvarPrevia(tester, 'feriados-${largura.toInt()}');
      await tester.ensureVisible(find.text('01-01-2026'));
      await tester.pumpAndSettle();
      expect(find.text('01-01-2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Pesquisa e categorias filtram os produtos em conjunto', (
    tester,
  ) async {
    final api = ApiDeTeste();
    await abrirTela(
      tester,
      Scaffold(
        body: TelaHome(
          produtos: api.produtos.map(Produto.fromJson).toList(),
          favoritos: {},
          onAdicionar: (_) {},
          onFavorito: (_) {},
        ),
      ),
      const Size(390, 844),
    );
    await tocar(tester, find.widgetWithText(ChoiceChip, 'Cookies'));
    expect(find.byType(ProdutoCard), findsOneWidget);
    expect(find.text('Cookie recheado'), findsOneWidget);
    expect(find.text('Brownie'), findsNothing);
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum doce encontrado.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tocar(tester, find.widgetWithText(ChoiceChip, 'Todos'));
    expect(find.byType(ProdutoCard), findsNWidgets(2));
  });

  for (final largura in [320.0, 1280.0]) {
    testWidgets(
      'Carrinho acomoda quantidades maiores e texto ampliado em $largura',
      (tester) async {
        final produtos = ApiDeTeste().produtos.map(Produto.fromJson).toList();
        final servico = PedidoService(
          cliente: MockClient((_) async => http.Response('', 500)),
        );
        addTearDown(servico.cliente.close);
        await abrirTela(
          tester,
          Scaffold(
            body: TelaCarrinho(
              produtos: produtos,
              carrinho: {1: 50, 3: 12},
              onAdicionar: (_) {},
              onRemover: (_) {},
              onPedidoFinalizado: () {},
              pedidoService: servico,
              chavePedidos: 'teste',
            ),
          ),
          Size(largura, 844),
          escala: 1.3,
        );
        await salvarPrevia(tester, 'carrinho-${largura.toInt()}');
        await tocar(tester, find.text('Confirmar pedido'));
        expect(
          find.text('Informe seu nome para retirar o pedido.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final largura in [390.0, 1280.0]) {
    testWidgets('Cardápio e Admin usam o tema da loja em $largura', (
      tester,
    ) async {
      final api = ApiDeTeste();
      api.produtos.addAll([
        {
          'id': 2,
          'nome': 'Cookie tradicional',
          'categoria': 'Cookies',
          'preco': 12,
          'imagem': 'assets/images/cookie_tradicional.png',
        },
        {
          'id': 5,
          'nome': 'Palha italiana',
          'categoria': 'Palhas italianas',
          'preco': 12,
          'imagem': 'assets/images/palha_italiana.png',
        },
      ]);
      await abrirTela(
        tester,
        NavBar(
          perfil: 'ADMIN',
          chaveAdmin: 'chave-teste',
          onSair: () {},
          servicoProdutos: ProdutoService(cliente: MockClient(api.responder)),
          servicoPedidos: PedidoService(cliente: MockClient(api.responder)),
        ),
        Size(largura, 844),
      );
      await salvarPrevia(tester, 'cardapio-${largura.toInt()}');
      await tocar(tester, find.text('Admin'));
      await salvarPrevia(tester, 'admin-${largura.toInt()}');
      expect(find.text('Administração'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
