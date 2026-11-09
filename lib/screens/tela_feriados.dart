import 'package:flutter/material.dart';
import '../components/app_widgets.dart';
import '../services/feriado_service.dart';
import '../theme/app_colors.dart';

class TelaFeriados extends StatefulWidget {
  final FeriadoService? servico;
  const TelaFeriados({super.key, this.servico});
  @override
  State<TelaFeriados> createState() => _TelaFeriadosState();
}

class _TelaFeriadosState extends State<TelaFeriados> {
  late final servico = widget.servico ?? FeriadoService();
  List<Feriado> feriados = [];
  bool carregando = true;
  String? erro;
  int ano = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    servico.cliente.close();
    super.dispose();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final lista = await servico.listarFeriados(ano);
      if (!mounted) return;
      setState(() {
        feriados = lista;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Feriados e retiradas')),
    body: PaginaConteudo(
      larguraMaxima: 800,
      children: [
        const CabecalhoPagina(
          etiqueta: 'CALENDÁRIO',
          titulo: 'Consulte os feriados',
          descricao: 'Mais tempo para planejar seus momentos doces.',
        ),
        const AvisoLoja(
          icone: Icons.school_outlined,
          texto:
              'Combine a data de retirada com a vendedora. '
              'Esta lista não confirma o funcionamento da faculdade.',
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Ano anterior',
                  onPressed: carregando
                      ? null
                      : () {
                          ano--;
                          carregar();
                        },
                  icon: const Icon(Icons.chevron_left, color: AppColors.roxo),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'ANO',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: AppColors.textoSuave,
                        ),
                      ),
                      Text(
                        '$ano',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.roxo,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo ano',
                  onPressed: carregando
                      ? null
                      : () {
                          ano++;
                          carregar();
                        },
                  icon: const Icon(Icons.chevron_right, color: AppColors.roxo),
                ),
                IconButton(
                  tooltip: 'Atualizar feriados',
                  onPressed: carregando ? null : carregar,
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: AppColors.roxo,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Dados da BrasilAPI · Feriados nacionais e de SP',
          style: TextStyle(fontSize: 11, color: AppColors.textoSuave),
        ),
        const SizedBox(height: 24),
        if (carregando)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (erro != null) ...[
          AvisoLoja(
            icone: Icons.wifi_off_outlined,
            texto: 'Não foi possível consultar: $erro',
          ),
          TextButton(
            onPressed: carregar,
            child: const Text('Tentar novamente'),
          ),
        ],
        if (!carregando && erro == null && feriados.isEmpty)
          const EstadoVazio(
            icone: Icons.event_outlined,
            titulo: 'Nenhum feriado retornado.',
            descricao: 'Experimente consultar outro ano.',
          ),
        if (!carregando && erro == null)
          for (final feriado in feriados)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.amarelo,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.event_outlined,
                          color: AppColors.roxo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feriado.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              feriado.dataFormatada,
                              style: const TextStyle(
                                color: AppColors.roxo,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
