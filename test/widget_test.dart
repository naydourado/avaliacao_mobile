import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sweets_by_isa/services/autenticacao_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sweets_by_isa/models/produto.dart';
import 'package:sweets_by_isa/models/pedido.dart';
import 'package:sweets_by_isa/screens/tela_home.dart';
import 'package:sweets_by_isa/screens/tela_login.dart';

void main() {
  test('Login recebe perfil da API', () async {
    final cliente = MockClient((request) async {
      expect(request.url.path, '/login');
      expect(request.method, 'POST');
      return http.Response('{"usuario":"admin","perfil":"ADMIN"}', 200);
    });
    final autenticacao = AutenticacaoService(cliente: cliente);
    final usuario = await autenticacao.entrar('admin', 'senha-teste');
    expect(usuario.administrador, true);
    cliente.close();
  });

  test('Converte produto do JSON da API e formata o preco', () {
    final produto = Produto.fromJson({
      'id': 1,
      'nome': 'Brownie',
      'categoria': 'Brownies',
      'preco': 12,
      'imagem': 'assets/images/brownie.png',
    });
    expect(produto.nome, 'Brownie');
    expect(produto, isA<Brownie>());
    expect(produto.precoFormatado, 'R\$ 12,00');
  });

  test('Converte pedido do JSON da API e mostra status', () {
    final pedido = Pedido.fromJson({
      'id': 1, 'codigo': 'codigo-de-exemplo', 'nome_cliente': 'Ana',
      'pagamento': 'PIX', 'observacoes': '', 'criado_em': '2026-10-28',
      'status': 'PRONTO', 'total': 24,
      'itens': [{'produto_nome': 'Brownie', 'quantidade': 2,
        'preco_unitario': 12}],
    });
    expect(pedido.statusFormatado, 'Pronto para retirada');
    expect(pedido.totalFormatado, 'R\$ 24,00');
    expect(pedido.itens.length, 1);
  });

  testWidgets('Login tem usuario e senha e valida campos vazios', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TelaLogin(onEntrar: (_, __) {}),
    ));
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Preencha usuário e senha.'), findsOneWidget);
  });

  testWidgets('Mostra o cardapio sem depender de internet', (tester) async {
    final produtos = [
      Produto(id: 1, nome: 'Brownie', categoria: 'Brownies', preco: 12,
          imagem: 'assets/images/brownie.png'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TelaHome(
          produtos: produtos,
          favoritos: <int>{},
          onAdicionar: (_) {},
          onFavorito: (_) {},
        ),
      ),
    ));
    expect(find.text('Nosso cardápio'), findsOneWidget);
    expect(find.text('Brownie'), findsOneWidget);
    expect(find.text('R\$ 12,00'), findsOneWidget);
  });
}
