import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweets_by_isa/navigation/navbar.dart';
import 'package:sweets_by_isa/services/pedido_service.dart';
import 'package:sweets_by_isa/services/produto_service.dart';
import 'package:sweets_by_isa/theme/app_theme.dart';

// Exercita as telas e os serviços reais; somente o transporte HTTP é simulado.
class ApiDeTeste {
  final produtos = <Map<String, dynamic>>[
    {
      'id': 1,
      'nome': 'Brownie',
      'categoria': 'Brownies',
      'preco': 12,
      'imagem': 'assets/images/brownie.png',
    },
    {
      'id': 3,
      'nome': 'Cookie recheado',
      'categoria': 'Cookies',
      'preco': 14,
      'imagem': 'assets/images/cookie_recheado.png',
    },
  ];
  final pedidos = <Map<String, dynamic>>[];

  Map<String, dynamic> pedido(String codigo) => {
    'id': pedidos.length + 1,
    'codigo': codigo,
    'nome_cliente': 'Ana',
    'pagamento': 'PIX',
    'observacoes': '',
    'criado_em': '2026-11-05T12:00:00Z',
    'status': 'RECEBIDO',
    'total': 38,
    'itens': [
      {'produto_nome': 'Brownie', 'quantidade': 2, 'preco_unitario': 12},
      {
        'produto_nome': 'Cookie recheado',
        'quantidade': 1,
        'preco_unitario': 14,
      },
    ],
  };

  Future<http.Response> responder(http.Request request) async {
    final caminho = request.url.path;
    final metodo = request.method;
    if ((caminho.startsWith('/produtos') && metodo != 'GET') ||
        (caminho == '/pedidos' && metodo == 'GET') ||
        metodo == 'PUT') {
      expect(request.headers['X-Admin-Key'], 'chave-teste');
    }
    Object? resposta;
    var status = 200;
    if (caminho == '/produtos' && metodo == 'GET') {
      resposta = produtos;
    } else if (caminho == '/produtos' && metodo == 'POST') {
      final dados = jsonDecode(request.body) as Map<String, dynamic>;
      produtos.add({...dados, 'id': 4});
      resposta = produtos.last;
      status = 201;
    } else if (caminho.startsWith('/produtos/') && metodo == 'PUT') {
      final id = int.parse(request.url.pathSegments.last);
      final dados = jsonDecode(request.body) as Map<String, dynamic>;
      produtos[produtos.indexWhere((p) => p['id'] == id)] = {
        ...dados,
        'id': id,
      };
      resposta = dados;
    } else if (caminho.startsWith('/produtos/') && metodo == 'DELETE') {
      final id = int.parse(request.url.pathSegments.last);
      produtos.removeWhere((p) => p['id'] == id);
      return http.Response('', 204);
    } else if (caminho == '/pedidos' && metodo == 'POST') {
      final dados = jsonDecode(request.body) as Map<String, dynamic>;
      expect(dados['nome_cliente'], 'Ana');
      expect(dados['pagamento'], 'PIX');
      expect(dados['itens'], [
        {'produto_id': 1, 'quantidade': 2},
        {'produto_id': 3, 'quantidade': 1},
      ]);
      expect(dados.containsKey('total'), isFalse);
      pedidos.add(pedido('novo-pedido'));
      resposta = pedidos.last;
      status = 201;
    } else if (caminho == '/pedidos' && metodo == 'GET') {
      resposta = pedidos;
    } else if (caminho.endsWith('/status') && metodo == 'PUT') {
      final id = int.parse(request.url.pathSegments[1]);
      final dados = jsonDecode(request.body) as Map<String, dynamic>;
      final encontrado = pedidos.firstWhere((p) => p['id'] == id);
      encontrado['status'] = dados['status'];
      resposta = encontrado;
    } else if (caminho.startsWith('/pedidos/') && metodo == 'GET') {
      resposta = pedidos.firstWhere(
        (p) => p['codigo'] == request.url.pathSegments.last,
      );
    } else {
      throw StateError('Requisição inesperada: $metodo $caminho');
    }
    return http.Response(
      jsonEncode(resposta),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

Future<void> abrirApp(
  WidgetTester tester,
  ApiDeTeste api, {
  String perfil = 'ADMIN',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.claro,
      home: NavBar(
        perfil: perfil,
        chaveAdmin: perfil == 'ADMIN' ? 'chave-teste' : '',
        onSair: () {},
        servicoProdutos: ProdutoService(cliente: MockClient(api.responder)),
        servicoPedidos: PedidoService(cliente: MockClient(api.responder)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await Scrollable.ensureVisible(tester.element(alvo), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final perfil in ['CLIENTE', 'ADMIN']) {
    for (final largura in [320.0, 390.0, 1280.0]) {
      testWidgets('$perfil: navegação e layout em $largura pixels', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(largura, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final api = ApiDeTeste();
        await abrirApp(tester, api, perfil: perfil);
        expect(find.text('Nosso cardápio'), findsOneWidget);
        if (perfil == 'ADMIN') {
          expect(find.text('Favoritos'), findsNothing);
          expect(find.byTooltip('Favoritar'), findsNothing);
          await tocar(tester, find.text('Admin'));
          expect(find.text('Administração'), findsOneWidget);
          await tocar(tester, find.text('Gerenciar pedidos'));
          expect(find.text('Nenhum pedido recebido.'), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position
              .jumpTo(0);
          await tester.pumpAndSettle();
          expect(find.text('Administração'), findsOneWidget);
        } else {
          expect(find.text('Admin'), findsNothing);
          await tocar(tester, find.byTooltip('Favoritar').first);
          await tocar(tester, find.text('Favoritos'));
          expect(find.text('Brownie'), findsOneWidget);
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getStringList('favoritos'), ['1']);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Admin cadastra, edita e exclui; cardápio acompanha alterações', (
    tester,
  ) async {
    final api = ApiDeTeste();
    await abrirApp(tester, api);
    await tocar(tester, find.text('Admin'));
    await tocar(tester, find.text('Gerenciar produtos'));
    await tocar(tester, find.text('Novo doce'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome'),
      'Brigadeiro',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Categoria'),
      'Docinhos',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Preço (R\$)'),
      '7,50',
    );
    await tocar(tester, find.text('Salvar'));
    await tester.scrollUntilVisible(
      find.text('Brigadeiro'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Brigadeiro'), findsOneWidget);
    expect(api.produtos.last['preco'], 7.5);
    expect(tester.takeException(), isNull);

    await tocar(tester, find.byTooltip('Editar').last);
    await tester.enterText(
      find.widgetWithText(TextField, 'Preço (R\$)'),
      '8,50',
    );
    await tocar(tester, find.text('Salvar'));
    expect(api.produtos.last['preco'], 8.5);
    expect(tester.takeException(), isNull);

    await tocar(tester, find.byTooltip('Excluir').last);
    await tocar(tester, find.text('Cancelar'));
    expect(api.produtos.length, 3);
    await tocar(tester, find.byTooltip('Excluir').last);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
    expect(find.text('Brigadeiro'), findsNothing);
    expect(api.produtos.length, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('2 produtos no cardápio.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin altera status e cliente consulta a alteração', (
    tester,
  ) async {
    final api = ApiDeTeste();
    api.pedidos.add(api.pedido('pedido-cliente'));
    SharedPreferences.setMockInitialValues({
      'pedidos_codigos': ['pedido-cliente'],
    });
    await abrirApp(tester, api);
    await tocar(tester, find.text('Admin'));
    await tocar(tester, find.text('Gerenciar pedidos'));
    await tocar(tester, find.byType(DropdownButtonFormField<String>));
    await tocar(tester, find.text('Em preparo').last);
    expect(api.pedidos.single['status'], 'EM_PREPARO');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await abrirApp(tester, api, perfil: 'CLIENTE');
    await tocar(tester, find.text('Pedidos'));
    expect(find.text('Status: Em preparo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin vê seu histórico separado do histórico do cliente', (
    tester,
  ) async {
    final api = ApiDeTeste();
    api.pedidos.add(api.pedido('pedido-cliente'));
    api.pedidos.add(api.pedido('pedido-admin'));
    SharedPreferences.setMockInitialValues({
      'pedidos_codigos': ['pedido-cliente'],
      'pedidos_codigos_admin': ['pedido-admin'],
    });
    await abrirApp(tester, api);
    await tocar(tester, find.text('Meus pedidos'));
    expect(find.text('Pedido #2'), findsOneWidget);
    expect(find.text('Pedido #1'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final perfil in ['CLIENTE', 'ADMIN']) {
    testWidgets(
      '$perfil finaliza compra de R\$ 38 e salva o código no seu histórico',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final api = ApiDeTeste();
        await abrirApp(tester, api, perfil: perfil);
        await tocar(tester, find.text('Adicionar').first);
        await tocar(tester, find.text('Adicionar').first);
        await tocar(tester, find.text('Adicionar').last);
        await tocar(tester, find.text('Carrinho'));
        await tester.enterText(
          find.widgetWithText(TextField, 'Seu nome'),
          'Ana',
        );
        await tocar(tester, find.text('Confirmar pedido'));
        expect(find.text('Total confirmado: R\$ 38,00'), findsOneWidget);
        await tocar(tester, find.text('Ver meus pedidos'));
        expect(find.text('Status: Recebido'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        final chave = perfil == 'ADMIN'
            ? 'pedidos_codigos_admin'
            : 'pedidos_codigos';
        expect(prefs.getStringList(chave), ['novo-pedido']);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
