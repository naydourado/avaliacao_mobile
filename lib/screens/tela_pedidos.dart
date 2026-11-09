import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../components/app_widgets.dart';
import '../components/pedido_card.dart';

class TelaPedidos extends StatefulWidget {
  final PedidoService pedidoService;
  final String chavePedidos;
  const TelaPedidos({
    super.key,
    required this.pedidoService,
    required this.chavePedidos,
  });

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
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final codigos = prefs.getStringList(widget.chavePedidos) ?? [];
      final lista = <Pedido>[];
      for (final codigo in codigos) {
        lista.add(await widget.pedidoService.consultarPedido(codigo));
      }
      if (!mounted) return;
      setState(() {
        pedidos = lista;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro =
            'Não foi possível consultar os pedidos. '
            '${e.toString().replaceFirst('Exception: ', '')}';
        carregando = false;
      });
    }
  }

  Future<void> buscarCodigo() async {
    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) return;
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      await widget.pedidoService.consultarPedido(codigo);
      final prefs = await SharedPreferences.getInstance();
      final codigos = prefs.getStringList(widget.chavePedidos) ?? [];
      if (!codigos.contains(codigo)) {
        codigos.insert(0, codigo);
        await prefs.setStringList(widget.chavePedidos, codigos);
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
  Widget build(BuildContext context) => PaginaConteudo(
    larguraMaxima: 800,
    children: [
      const CabecalhoPagina(
        etiqueta: 'CADA ETAPA, UM CARINHO',
        titulo: 'Meus pedidos',
        descricao: 'Acompanhe seus pedidos salvos neste dispositivo.',
      ),
      TextField(
        controller: codigoController,
        decoration: InputDecoration(
          labelText: 'Consultar pelo código do pedido',
          prefixIcon: const Icon(Icons.receipt_long_outlined),
          suffixIcon: IconButton(
            tooltip: 'Buscar pedido',
            onPressed: carregando ? null : buscarCodigo,
            icon: const Icon(Icons.search),
          ),
        ),
        onSubmitted: (_) {
          if (!carregando) buscarCodigo();
        },
      ),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: carregando ? null : carregarPedidos,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Atualizar pedidos'),
        ),
      ),
      const SizedBox(height: 24),
      if (carregando)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (erro != null) AvisoLoja(icone: Icons.error_outline, texto: erro!),
      if (!carregando && pedidos.isEmpty && erro == null)
        const EstadoVazio(
          icone: Icons.receipt_long_outlined,
          titulo: 'Nenhum pedido salvo ainda.',
          descricao: 'Seu próximo momento doce pode começar no cardápio.',
        ),
      for (final pedido in pedidos) PedidoCard(pedido: pedido),
    ],
  );
}
