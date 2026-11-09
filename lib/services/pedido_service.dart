import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import 'produto_service.dart';

class PedidoService {
  final http.Client cliente;
  PedidoService({http.Client? cliente}) : cliente = cliente ?? http.Client();

  String get apiUrl => ProdutoService.apiUrl;

  // POST: cria pedido de verdade. Os preços são calculados no servidor.
  Future<Pedido> criarPedido(
    String nome,
    String pagamento,
    String observacoes,
    Map<int, int> carrinho,
  ) async {
    final resposta = await cliente
        .post(
          Uri.parse('$apiUrl/pedidos'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'nome_cliente': nome,
            'pagamento': pagamento,
            'observacoes': observacoes,
            'itens': carrinho.entries
                .map((e) => {'produto_id': e.key, 'quantidade': e.value})
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 15));
    verificarResposta(resposta);
    return Pedido.fromJson(
      jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>,
    );
  }

  // GET por código aleatório: cliente consulta apenas pedidos que conhece.
  Future<Pedido> consultarPedido(String codigo) async {
    final resposta = await cliente
        .get(Uri.parse('$apiUrl/pedidos/${Uri.encodeComponent(codigo)}'))
        .timeout(const Duration(seconds: 10));
    verificarResposta(resposta);
    return Pedido.fromJson(
      jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>,
    );
  }

  // GET e PUT administrativos: a mesma chave usada na gestão dos produtos.
  Future<List<Pedido>> listarPedidos(String chave) async {
    final resposta = await cliente
        .get(Uri.parse('$apiUrl/pedidos'), headers: {'X-Admin-Key': chave})
        .timeout(const Duration(seconds: 10));
    verificarResposta(resposta);
    final dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as List;
    return dados
        .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> atualizarStatus(int id, String status, String chave) async {
    final resposta = await cliente
        .put(
          Uri.parse('$apiUrl/pedidos/$id/status'),
          headers: {'X-Admin-Key': chave, 'Content-Type': 'application/json'},
          body: jsonEncode({'status': status}),
        )
        .timeout(const Duration(seconds: 10));
    verificarResposta(resposta);
  }

  void verificarResposta(http.Response resposta) {
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) return;
    String mensagem = 'Erro ${resposta.statusCode} na API.';
    try {
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (dados is Map && dados['detail'] is String) {
        mensagem = dados['detail'] as String;
      }
    } catch (_) {
      // A resposta pode não ter um JSON.
    }
    throw Exception(mensagem);
  }
}
