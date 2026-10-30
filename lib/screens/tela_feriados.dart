import 'package:flutter/material.dart';
import '../services/feriado_service.dart';
import '../theme/app_colors.dart';

class TelaFeriados extends StatefulWidget {
  const TelaFeriados({super.key});

  @override
  State<TelaFeriados> createState() => _TelaFeriadosState();
}

class _TelaFeriadosState extends State<TelaFeriados> {
  final servico = FeriadoService();
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
    setState(() { carregando = true; erro = null; });
    try {
      final lista = await servico.listarFeriados(ano);
      if (!mounted) return;
      setState(() { feriados = lista; carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feriados e retiradas')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Consulte os feriados', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.roxo)),
        const SizedBox(height: 8),
        const Text('Dados da BrasilAPI (feriados nacionais e de SP). '
          'Atenção: a data de retirada precisa ser combinada com a vendedora. '
          'Esta lista não confirma o funcionamento da faculdade.'),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Ano: '),
          TextButton(onPressed: () { ano--; carregar(); },
            child: const Icon(Icons.chevron_left)),
          Text('$ano'),
          TextButton(onPressed: () { ano++; carregar(); },
            child: const Icon(Icons.chevron_right)),
          IconButton(onPressed: carregar, icon: const Icon(Icons.refresh)),
        ]),
        if (carregando) const Center(child: CircularProgressIndicator()),
        if (erro != null) Text('Não foi possível consultar: $erro'),
        if (!carregando && erro == null && feriados.isEmpty)
          const Text('Nenhum feriado retornado.'),
        for (final feriado in feriados)
          Card(color: Colors.white, child: ListTile(
            leading: const Icon(Icons.event, color: AppColors.roxo),
            title: Text(feriado.nome), subtitle: Text(feriado.data),
          )),
      ]),
    );
  }
}
