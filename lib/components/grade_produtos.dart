import 'package:flutter/material.dart';
import '../models/produto.dart';
import 'produto_card.dart';

class GradeProdutos extends StatelessWidget {
  final List<Produto> produtos;
  final Set<int> favoritos;
  final void Function(Produto) onAdicionar;
  final void Function(int) onFavorito;
  final bool mostrarFavoritos;
  const GradeProdutos({
    super.key,
    required this.produtos,
    required this.favoritos,
    required this.onAdicionar,
    required this.onFavorito,
    this.mostrarFavoritos = true,
  });
  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, tamanho) {
      final colunas = tamanho.crossAxisExtent < 330
          ? 1
          : (tamanho.crossAxisExtent / 260).ceil().clamp(2, 4);
      final escala = MediaQuery.textScalerOf(context).scale(14) / 14;
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: colunas,
          mainAxisExtent: (colunas == 1 ? 390.0 : 330.0) + (escala - 1) * 160,
          mainAxisSpacing: 18,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final produto = produtos[index];
          return ProdutoCard(
            produto: produto,
            favorito: favoritos.contains(produto.id),
            onAdicionar: () => onAdicionar(produto),
            onFavorito: () => onFavorito(produto.id),
            mostrarFavorito: mostrarFavoritos,
          );
        }, childCount: produtos.length),
      );
    },
  );
}
