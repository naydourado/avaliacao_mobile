import 'package:flutter/material.dart';
import '../components/produto_card.dart';
import '../models/produto.dart';
import '../theme/app_colors.dart';

class TelaFavoritos extends StatelessWidget {
  final List<Produto> produtos;
  final Set<int> favoritos;
  final void Function(Produto) onAdicionar;
  final void Function(int) onFavorito;

  const TelaFavoritos({
    super.key,
    required this.produtos,
    required this.favoritos,
    required this.onAdicionar,
    required this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final lista = produtos.where((p) => favoritos.contains(p.id)).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus favoritos',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold,
                color: AppColors.roxo),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('Toque no coração para favoritar um doce.'))
                : GridView.builder(
                    itemCount: lista.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 265,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final produto = lista[index];
                      return ProdutoCard(
                        produto: produto,
                        favorito: true,
                        onAdicionar: () => onAdicionar(produto),
                        onFavorito: () => onFavorito(produto.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
