import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../components/app_widgets.dart';
import '../components/pedido_card.dart';

class TelaGestaoPedidos extends StatefulWidget {
  final PedidoService pedidoService;
  final String chave;
  const TelaGestaoPedidos({
    super.key,
    required this.pedidoService,
    required this.chave,
  });

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
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final lista = await widget.pedidoService.listarPedidos(widget.chave);
      if (!mounted) return;
      setState(() {
        pedidos = lista;
        carregando = false;
      });
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
        pedido.id,
        status,
        widget.chave,
      );
      await carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status do pedido atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => atualizando = null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pedidos recebidos'),
      actions: [
        IconButton(
          tooltip: 'Atualizar pedidos',
          onPressed: carregar,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: carregando
        ? const Center(child: CircularProgressIndicator())
        : PaginaConteudo(
            larguraMaxima: 800,
            children: [
              CabecalhoPagina(
                etiqueta: 'ACOMPANHAMENTO DA LOJA',
                titulo: 'Pedidos recebidos (${pedidos.length})',
                descricao: 'Do primeiro pedido ao último detalhe da retirada.',
              ),
              if (erro != null) ...[
                AvisoLoja(icone: Icons.error_outline, texto: erro!),
                TextButton(
                  onPressed: carregar,
                  child: const Text('Tentar novamente'),
                ),
              ] else if (pedidos.isEmpty)
                const EstadoVazio(
                  icone: Icons.receipt_long_outlined,
                  titulo: 'Nenhum pedido recebido.',
                  descricao: 'Os novos pedidos aparecerão por aqui.',
                )
              else
                for (final pedido in pedidos)
                  PedidoCard(
                    pedido: pedido,
                    mostrarCodigo: false,
                    acao: DropdownButtonFormField<String>(
                      key: ValueKey(
                        '${pedido.id}-${pedido.status}-$atualizando',
                      ),
                      initialValue: pedido.status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Status do pedido',
                      ),
                      items: statusOpcoes.entries
                          .map(
                            (opcao) => DropdownMenuItem(
                              value: opcao.key,
                              child: Text(opcao.value),
                            ),
                          )
                          .toList(),
                      onChanged: atualizando != null
                          ? null
                          : (valor) {
                              if (valor != null && valor != pedido.status) {
                                mudarStatus(pedido, valor);
                              }
                            },
                    ),
                  ),
            ],
          ),
  );
}
