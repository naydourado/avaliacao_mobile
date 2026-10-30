import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';

class TelaGestaoPedidos extends StatefulWidget {
  final PedidoService pedidoService;
  final String chave;
  const TelaGestaoPedidos({super.key, required this.pedidoService,
    required this.chave});

  @override
  State<TelaGestaoPedidos> createState() => _TelaGestaoPedidosState();
}

class _TelaGestaoPedidosState extends State<TelaGestaoPedidos> {
  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erro;
  int? atualizando;

  static const statusOpcoes = {
    'RECEBIDO': 'Recebido',
    'EM_PREPARO': 'Em preparo',
    'PRONTO': 'Pronto para retirada',
    'ENTREGUE': 'Entregue',
    'CANCELADO': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() { carregando = true; erro = null; });
    try {
      final lista = await widget.pedidoService.listarPedidos(widget.chave);
      if (!mounted) return;
      setState(() { pedidos = lista; carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  Future<void> mudarStatus(Pedido pedido, String status) async {
    setState(() => atualizando = pedido.id);
    try {
      await widget.pedidoService.atualizarStatus(
        pedido.id, status, widget.chave);
      await carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Status do pedido atualizado!'),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => atualizando = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos recebidos'), actions: [
        IconButton(onPressed: carregar, icon: const Icon(Icons.refresh)),
      ]),
      body: carregando
        ? const Center(child: CircularProgressIndicator())
        : erro != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Erro: $erro', textAlign: TextAlign.center),
                TextButton(onPressed: carregar, child: const Text('Tentar novamente')),
              ]),
            ))
          : pedidos.isEmpty
            ? const Center(child: Text('Nenhum pedido recebido.'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pedidos recebidos (${pedidos.length})',
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.roxo)),
                        const SizedBox(height: 5),
                        const Text('Selecione o status de cada pedido. '
                            'A alteração será salva na API.'),
                      ],
                    ),
                  ),
                  Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  return Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedido #${pedido.id} - ${pedido.nomeCliente}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Pagamento: ${pedido.pagamento}'),
                          Text('Total: ${pedido.totalFormatado}'),
                          const SizedBox(height: 6),
                          for (final item in pedido.itens)
                            Text('${item.quantidade}x ${item.nome}'),
                          if (pedido.observacoes.isNotEmpty)
                            Text('Obs.: ${pedido.observacoes}'),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: pedido.status,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status do pedido',
                              border: OutlineInputBorder()),
                            items: statusOpcoes.entries.map((opcao) =>
                              DropdownMenuItem(value: opcao.key,
                                child: Text(opcao.value))).toList(),
                            onChanged: atualizando != null ? null : (valor) {
                              if (valor != null && valor != pedido.status) {
                                mudarStatus(pedido, valor);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
    );
  }
}
