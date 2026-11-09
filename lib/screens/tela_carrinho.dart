import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';
import '../components/app_widgets.dart';

class TelaCarrinho extends StatefulWidget {
  final List<Produto> produtos;
  final Map<int, int> carrinho;
  final void Function(int) onAdicionar;
  final void Function(int) onRemover;
  final VoidCallback onPedidoFinalizado;
  final PedidoService pedidoService;
  final String chavePedidos;

  const TelaCarrinho({
    super.key,
    required this.produtos,
    required this.carrinho,
    required this.onAdicionar,
    required this.onRemover,
    required this.onPedidoFinalizado,
    required this.pedidoService,
    required this.chavePedidos,
  });

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
        const SnackBar(
          content: Text('Informe seu nome para retirar o pedido.'),
        ),
      );
      return;
    }
    setState(() => enviando = true);
    try {
      final pedido = await widget.pedidoService.criarPedido(
        nomeController.text.trim(),
        pagamento,
        observacoesController.text.trim(),
        Map<int, int>.from(widget.carrinho),
      );
      bool salvo = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        final codigos = prefs.getStringList(widget.chavePedidos) ?? [];
        if (!codigos.contains(pedido.codigo)) codigos.insert(0, pedido.codigo);
        salvo = await prefs.setStringList(widget.chavePedidos, codigos);
      } catch (_) {
        salvo = false;
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pedido recebido!'),
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.roxo,
            size: 48,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total confirmado: ${pedido.totalFormatado}'),
                const SizedBox(height: 10),
                const Text('Código para acompanhar seu pedido:'),
                SelectableText(
                  pedido.codigo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: pedido.codigo)),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar código'),
                ),
                const Text(
                  'Retirada na faculdade, a combinar. '
                  'Pagamento por Pix ou dinheiro na retirada.',
                ),
                if (!salvo)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Não foi possível salvar o código no dispositivo. '
                      'Copie-o para consultar o pedido depois.',
                    ),
                  ),
              ],
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Widget itemCarrinho(Produto produto) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ImagemDoce(caminho: produto.imagem, tamanho: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${produto.precoFormatado} cada',
                        style: const TextStyle(
                          color: AppColors.textoSuave,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  moeda(produto.preco * widget.carrinho[produto.id]!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.roxo,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lavanda,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Remover uma unidade',
                        onPressed: enviando
                            ? null
                            : () => widget.onRemover(produto.id),
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      SizedBox(
                        width: 26,
                        child: Text(
                          '${widget.carrinho[produto.id]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Adicionar uma unidade',
                        onPressed: enviando
                            ? null
                            : () => widget.onAdicionar(produto.id),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget formularioRetirada() => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados para retirada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.roxo,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Só mais alguns detalhes para preparar seu pedido.',
            style: TextStyle(color: AppColors.textoSuave, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nomeController,
            maxLength: 100,
            enabled: !enviando,
            decoration: const InputDecoration(
              labelText: 'Seu nome',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: pagamento,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Forma de pagamento',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'PIX', child: Text('Pix')),
              DropdownMenuItem(value: 'DINHEIRO', child: Text('Dinheiro')),
            ],
            onChanged: enviando
                ? null
                : (valor) => setState(() => pagamento = valor ?? 'PIX'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: observacoesController,
            maxLength: 250,
            maxLines: 3,
            enabled: !enviando,
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              alignLabelWithHint: true,
              hintText: 'Algo que precisamos saber?',
            ),
          ),
        ],
      ),
    ),
  );

  Widget resumoPedido(double total, int quantidade) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.amarelo,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Resumo do pedido',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.roxo,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$quantidade ${quantidade == 1 ? 'doce escolhido' : 'doces escolhidos'}',
          style: const TextStyle(color: AppColors.roxo),
        ),
        const SizedBox(height: 24),
        const Text('Total estimado:', style: TextStyle(color: AppColors.roxo)),
        const SizedBox(height: 4),
        Text(
          moeda(total),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.roxo,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Retirada na faculdade, a combinar. Não há delivery.',
          style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.roxo),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: enviando ? null : finalizar,
          icon: const Icon(Icons.shopping_bag_outlined, size: 20),
          label: Text(enviando ? 'Enviando pedido...' : 'Confirmar pedido'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final itens = widget.produtos
        .where((p) => widget.carrinho.containsKey(p.id))
        .toList();
    final total = itens.fold<double>(
      0,
      (soma, p) => soma + p.preco * widget.carrinho[p.id]!,
    );
    final quantidade = widget.carrinho.values.fold<int>(
      0,
      (soma, qtd) => soma + qtd,
    );
    return PaginaConteudo(
      children: [
        const CabecalhoPagina(
          etiqueta: 'QUASE PRONTO',
          titulo: 'Meu carrinho',
          descricao: 'Uma seleção de coisas boas, feita por você.',
        ),
        if (itens.isEmpty)
          const EstadoVazio(
            icone: Icons.shopping_bag_outlined,
            titulo: 'Seu carrinho está vazio.',
            descricao: 'Escolha seus doces no cardápio e volte para finalizar.',
          )
        else
          LayoutBuilder(
            builder: (context, tamanho) {
              final detalhes = Column(
                children: [
                  for (final produto in itens) itemCarrinho(produto),
                  const SizedBox(height: 12),
                  formularioRetirada(),
                ],
              );
              final resumo = resumoPedido(total, quantidade);
              if (tamanho.maxWidth >= 850) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: detalhes),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: resumo),
                  ],
                );
              }
              return Column(
                children: [detalhes, const SizedBox(height: 20), resumo],
              );
            },
          ),
      ],
    );
  }
}
