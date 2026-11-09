import 'package:flutter/material.dart';
import '../components/app_widgets.dart';
import '../services/produto_service.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';
import 'tela_gestao.dart';
import 'tela_gestao_pedidos.dart';

class TelaAdmin extends StatelessWidget {
  final int quantidadeProdutos;
  final ProdutoService produtoService;
  final PedidoService pedidoService;
  final String chaveAdmin;
  final Future<void> Function() onProdutosAlterados;
  const TelaAdmin({
    super.key,
    required this.quantidadeProdutos,
    required this.produtoService,
    required this.pedidoService,
    required this.chaveAdmin,
    required this.onProdutosAlterados,
  });

  void abrirProdutos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaGestao(
          produtoService: produtoService,
          chaveAdmin: chaveAdmin,
          onAlterado: onProdutosAlterados,
        ),
      ),
    );
  }

  void abrirPedidos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaGestaoPedidos(pedidoService: pedidoService, chave: chaveAdmin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PaginaConteudo(
    children: [
      const CabecalhoPagina(
        etiqueta: 'PAINEL DA LOJA',
        titulo: 'Administração',
        descricao: 'Seu cardápio e seus pedidos, bem organizados.',
      ),
      LayoutBuilder(
        builder: (context, tamanho) {
          final produtos = _AtalhoAdmin(
            icone: Icons.inventory_2_outlined,
            titulo: 'Produtos',
            detalhe: '$quantidadeProdutos produtos no cardápio.',
            descricao:
                'Cuide dos doces da loja: cadastre, edite os detalhes e atualize os preços.',
            botao: 'Gerenciar produtos',
            onPressed: () => abrirProdutos(context),
          );
          final pedidos = _AtalhoAdmin(
            icone: Icons.receipt_long_outlined,
            titulo: 'Pedidos recebidos',
            detalhe: 'Do preparo até a retirada.',
            descricao:
                'Veja o que chegou e mantenha seus clientes por dentro de cada etapa.',
            botao: 'Gerenciar pedidos',
            onPressed: () => abrirPedidos(context),
            amarelo: true,
          );
          if (tamanho.maxWidth >= 760) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: produtos),
                const SizedBox(width: 20),
                Expanded(child: pedidos),
              ],
            );
          }
          return Column(
            children: [produtos, const SizedBox(height: 20), pedidos],
          );
        },
      ),
      const SizedBox(height: 24),
      const AvisoLoja(
        icone: Icons.lock_outline,
        texto:
            'Área exclusiva da administradora. As alterações ficam salvas na loja.',
      ),
    ],
  );
}

class _AtalhoAdmin extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String detalhe;
  final String descricao;
  final String botao;
  final VoidCallback onPressed;
  final bool amarelo;
  const _AtalhoAdmin({
    required this.icone,
    required this.titulo,
    required this.detalhe,
    required this.descricao,
    required this.botao,
    required this.onPressed,
    this.amarelo = false,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: amarelo ? AppColors.amarelo : AppColors.lavanda,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icone, size: 28, color: AppColors.roxo),
          ),
          const SizedBox(height: 24),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 23,
              color: AppColors.roxo,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(detalhe, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            descricao,
            style: const TextStyle(color: AppColors.textoSuave, height: 1.6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onPressed, child: Text(botao)),
          ),
        ],
      ),
    ),
  );
}
