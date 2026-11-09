import 'dart:io';

import 'package:sweets_by_isa/services/feriado_service.dart';

// Verificação real da segunda API, sem alterar dados do projeto.
Future<void> main() async {
  final servico = FeriadoService();
  try {
    final ano = DateTime.now().year;
    final feriados = await servico.listarFeriados(ano);
    if (feriados.isEmpty) throw StateError('A lista retornada está vazia.');
    stdout.writeln(
      'BrasilAPI: ${feriados.length} feriados recebidos para $ano.',
    );
  } catch (erro) {
    stderr.writeln('Falha na integração com a BrasilAPI: $erro');
    exitCode = 1;
  } finally {
    servico.cliente.close();
  }
}
