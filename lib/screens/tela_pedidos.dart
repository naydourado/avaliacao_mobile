import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';

class TelaPedidos extends StatefulWidget {
  final PedidoService pedidoService;
  const TelaPedidos({super.key, required this.pedidoService});

  @override
  State<TelaPedidos> createState() => _TelaPedidosState();
}

class _TelaPedidosState extends State<TelaPedidos> {
  final codigoController = TextEditingController();
  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  Future<void> carregarPedidos() async {
    setState(() { carregando = true; erro = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final codigos = prefs.getStringList('pedidos_codigos') ?? [];
      final lista = <Pedido>[];
      for (final codigo in codigos) {
        lista.add(await widget.pedidoService.consultarPedido(codigo));
      }
      if (!mounted) return;
      setState(() { pedidos = lista; carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível consultar os pedidos. '
          '${e.toString().replaceFirst('Exception: ', '')}';
        carregando = false;
      });
    }
  }

  Future<void> buscarCodigo() async {
    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) return;
    setState(() { carregando = true; erro = null; });
    try {
      await widget.pedidoService.consultarPedido(codigo);
      final prefs = await SharedPreferences.getInstance();
      final codigos = prefs.getStringList('pedidos_codigos') ?? [];
      if (!codigos.contains(codigo)) {
        codigos.insert(0, codigo);
        await prefs.setStringList('pedidos_codigos', codigos);
      }
      codigoController.clear();
      if (mounted) await carregarPedidos();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Meus pedidos', style: TextStyle(fontSize: 23,
          fontWeight: FontWeight.bold, color: AppColors.roxo)),
        const SizedBox(height: 8),
        const Text('Acompanhe seus pedidos salvos neste dispositivo.'),
        const SizedBox(height: 12),
        TextField(
          controller: codigoController,
          decoration: InputDecoration(
            labelText: 'Consultar pelo código do pedido',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: 'Buscar pedido',
              onPressed: carregando ? null : buscarCodigo,
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (_) { if (!carregando) buscarCodigo(); },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: carregando ? null : carregarPedidos,
          icon: const Icon(Icons.refresh), label: const Text('Atualizar pedidos')),
        if (carregando) const Padding(
          padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        if (erro != null) Padding(
          padding: const EdgeInsets.all(12), child: Text(erro!,
            style: const TextStyle(color: Colors.red))),
        if (!carregando && pedidos.isEmpty && erro == null)
          const Padding(padding: EdgeInsets.all(24),
            child: Center(child: Text('Nenhum pedido salvo ainda.'))),
        for (final pedido in pedidos) Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido #${pedido.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text('Status: ${pedido.statusFormatado}',
                  style: const TextStyle(color: AppColors.roxo,
                    fontWeight: FontWeight.w600)),
                Text('Nome: ${pedido.nomeCliente}'),
                Text('Pagamento: ${pedido.pagamento}'),
                const SizedBox(height: 8),
                for (final item in pedido.itens)
                  Text('${item.quantidade}x ${item.nome}'),
                const SizedBox(height: 8),
                Text('Total: ${pedido.totalFormatado}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                SelectableText('Código: ${pedido.codigo}',
                  style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
