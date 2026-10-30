import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'produto_service.dart';

class AutenticacaoService {
  final http.Client cliente;

  AutenticacaoService({http.Client? cliente})
      : cliente = cliente ?? http.Client();

  Future<Usuario> entrar(String usuario, String senha) async {
    final resposta = await cliente.post(
      Uri.parse('${ProdutoService.apiUrl}/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'usuario': usuario, 'senha': senha}),
    ).timeout(const Duration(seconds: 10));

    if (resposta.statusCode != 200) {
      var mensagem = 'Não foi possível fazer login.';
      try {
        final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
        if (dados is Map && dados['detail'] is String) {
          mensagem = dados['detail'] as String;
        }
      } catch (_) {
        // Algumas mensagens de erro da API não contêm JSON.
      }
      throw Exception(mensagem);
    }
    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
    return Usuario.fromJson(dados as Map<String, dynamic>);
  }
}
