import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../theme/app_colors.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final bool favorito;
  final VoidCallback onAdicionar;
  final VoidCallback onFavorito;
  final bool mostrarFavorito;

  const ProdutoCard({
    super.key,
    required this.produto,
    required this.favorito,
    required this.onAdicionar,
    required this.onFavorito,
    this.mostrarFavorito = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.branco,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  produto.imagem,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.cookie, size: 55)),
                ),
                if (mostrarFavorito) Positioned(
                  right: 6,
                  top: 6,
                  child: IconButton.filledTonal(
                    tooltip: 'Favoritar',
                    onPressed: onFavorito,
                    icon: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.roxo,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            child: Text(
              produto.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              produto.precoFormatado,
              style: const TextStyle(
                color: AppColors.roxo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 3, 6, 7),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: FilledButton(
                onPressed: onAdicionar,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Adicionar', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
