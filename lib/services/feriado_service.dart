import 'dart:convert';
import 'package:http/http.dart' as http;

class Feriado {
  final String data;
  final String nome;
  Feriado({required this.data, required this.nome});
  factory Feriado.fromJson(Map<String, dynamic> json) => Feriado(
    data: json['date'] as String, nome: json['name'] as String);
}

// Segunda API REST, independente da API Sweets by Isa.
class FeriadoService {
  final http.Client cliente;
  FeriadoService({http.Client? cliente}) : cliente = cliente ?? http.Client();

  Future<List<Feriado>> listarFeriados(int ano) async {
    final resposta = await cliente.get(Uri.parse(
      'https://brasilapi.com.br/api/feriados/v1/$ano?uf=SP',
    )).timeout(const Duration(seconds: 12));
    if (resposta.statusCode != 200) {
      throw Exception('A BrasilAPI respondeu ${resposta.statusCode}.');
    }
    final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List;
    return lista.map((item) => Feriado.fromJson(
      item as Map<String, dynamic>)).toList();
  }
}
