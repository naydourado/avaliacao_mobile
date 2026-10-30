import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';

class TelaCarrinho extends StatefulWidget {
  final List<Produto> produtos;
  final Map<int, int> carrinho;
  final void Function(int) onAdicionar;
  final void Function(int) onRemover;
  final VoidCallback onPedidoFinalizado;
  final PedidoService pedidoService;

  const TelaCarrinho({super.key, required this.produtos, required this.carrinho,
    required this.onAdicionar, required this.onRemover,
    required this.onPedidoFinalizado, required this.pedidoService});

  @override
  State<TelaCarrinho> createState() => _TelaCarrinhoState();
}

class _TelaCarrinhoState extends State<TelaCarrinho> {
  final nomeController = TextEditingController();
  final observacoesController = TextEditingController();
  String pagamento = 'PIX';
  bool enviando = false;

  String moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  void dispose() {
    nomeController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> finalizar() async {
    if (enviando) return;
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome para retirar o pedido.')));
      return;
    }
    setState(() => enviando = true);
    try {
      final pedido = await widget.pedidoService.criarPedido(
        nomeController.text.trim(), pagamento,
        observacoesController.text.trim(), Map<int, int>.from(widget.carrinho),
      );
      bool salvo = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        final codigos = prefs.getStringList('pedidos_codigos') ?? [];
        if (!codigos.contains(pedido.codigo)) codigos.insert(0, pedido.codigo);
        salvo = await prefs.setStringList('pedidos_codigos', codigos);
      } catch (_) {
        salvo = false;
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pedido recebido!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total confirmado: ${pedido.totalFormatado}'),
              const SizedBox(height: 10),
              const Text('Código para acompanhar seu pedido:'),
              SelectableText(pedido.codigo,
                style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: pedido.codigo)),
                icon: const Icon(Icons.copy), label: const Text('Copiar código'),
              ),
              const Text('Retirada na faculdade, a combinar. '
                'Pagamento por Pix ou dinheiro na retirada.'),
              if (!salvo) const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Não foi possível salvar o código no dispositivo. '
                  'Copie-o para consultar o pedido depois.'),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Ver meus pedidos'),
            ),
          ],
        ),
      );
      if (mounted) widget.onPedidoFinalizado();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
      ));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.produtos.where((p) => widget.carrinho.containsKey(p.id)).toList();
    double total = 0;
    for (final produto in itens) {
      total += produto.preco * widget.carrinho[produto.id]!;
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Meu carrinho', style: TextStyle(
          fontSize: 23, fontWeight: FontWeight.bold, color: AppColors.roxo)),
        const SizedBox(height: 12),
        if (itens.isEmpty)
          const Padding(padding: EdgeInsets.all(24),
            child: Center(child: Text('Seu carrinho está vazio.'))),
        for (final produto in itens)
          Card(
            color: Colors.white,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(produto.imagem,
                  width: 50, height: 50, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.cookie)),
              ),
              title: Text(produto.nome),
              subtitle: Text('${produto.precoFormatado} cada'),
              trailing: SizedBox(width: 116,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    onPressed: enviando ? null : () => widget.onRemover(produto.id),
                    icon: const Icon(Icons.remove_circle_outline)),
                  Text('${widget.carrinho[produto.id]}'),
                  IconButton(
                    onPressed: enviando ? null : () => widget.onAdicionar(produto.id),
                    icon: const Icon(Icons.add_circle_outline)),
                ]),
              ),
            ),
          ),
          if (itens.isNotEmpty) ...[
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total estimado:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(moeda(total), style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.roxo)),
            ]),
            const SizedBox(height: 10),
            TextField(
              controller: nomeController,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Seu nome',
                border: OutlineInputBorder()),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: pagamento,
              decoration: const InputDecoration(labelText: 'Forma de pagamento',
                border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'PIX', child: Text('Pix')),
                DropdownMenuItem(value: 'DINHEIRO', child: Text('Dinheiro')),
              ],
              onChanged: enviando ? null : (valor) => setState(() => pagamento = valor ?? 'PIX'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: observacoesController,
              maxLength: 250,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Observações (opcional)',
                border: OutlineInputBorder()),
            ),
            const Text('Retirada na faculdade, a combinar. Não há delivery.',
              style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enviando ? null : finalizar,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(enviando ? 'Enviando pedido...' : 'Confirmar pedido'),
              ),
            ),
          ],
      ],
    );
  }
}
