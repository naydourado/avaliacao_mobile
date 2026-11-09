import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto.dart';

class ProdutoService {
  // Chrome: http://127.0.0.1:8000
  // Emulador Android: http://10.0.2.2:8000
  // Endereco alternativo: flutter run --dart-define=API_URL=http://...
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  final http.Client cliente;
  ProdutoService({http.Client? cliente}) : cliente = cliente ?? http.Client();

  // GET - todos os produtos
  Future<List<Produto>> listarProdutos() async {
    final resposta = await cliente
        .get(Uri.parse('$apiUrl/produtos'))
        .timeout(const Duration(seconds: 10));
    _verificarResposta(resposta);
    final dados = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
    return dados
        .map((item) => Produto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // POST - criar um produto (chave informada pela administradora)
  Future<void> criarProduto(
    String nome,
    String categoria,
    double preco,
    String chave,
  ) async {
    final resposta = await cliente
        .post(
          Uri.parse('$apiUrl/produtos'),
          headers: _cabecalhos(chave),
          body: jsonEncode({
            'nome': nome,
            'categoria': categoria,
            'preco': preco,
            'imagem': 'assets/images/doce_padrao.png',
          }),
        )
        .timeout(const Duration(seconds: 10));
    _verificarResposta(resposta);
  }

  // PUT - atualizar um produto existente
  Future<void> editarProduto(
    Produto produto,
    String nome,
    String categoria,
    double preco,
    String chave,
  ) async {
    final resposta = await cliente
        .put(
          Uri.parse('$apiUrl/produtos/${produto.id}'),
          headers: _cabecalhos(chave),
          body: jsonEncode({
            'nome': nome,
            'categoria': categoria,
            'preco': preco,
            'imagem': produto.imagem,
          }),
        )
        .timeout(const Duration(seconds: 10));
    _verificarResposta(resposta);
  }

  // DELETE - excluir permanentemente um produto
  Future<void> excluirProduto(int id, String chave) async {
    final resposta = await cliente
        .delete(Uri.parse('$apiUrl/produtos/$id'), headers: _cabecalhos(chave))
        .timeout(const Duration(seconds: 10));
    _verificarResposta(resposta);
  }

  Map<String, String> _cabecalhos(String chave) => {
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Admin-Key': chave,
  };

  void _verificarResposta(http.Response resposta) {
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) return;
    String mensagem = 'Erro ${resposta.statusCode} na API.';
    try {
      final erro = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (erro is Map && erro['detail'] is String) {
        mensagem = erro['detail'] as String;
      }
    } catch (_) {
      // Algumas respostas de erro nao possuem JSON.
    }
    throw Exception(mensagem);
  }
}
