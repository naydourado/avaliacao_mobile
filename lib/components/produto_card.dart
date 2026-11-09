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
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
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
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.lavanda,
                  child: Icon(
                    Icons.cookie_outlined,
                    size: 48,
                    color: AppColors.roxo,
                  ),
                ),
              ),
              if (mostrarFavorito)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton.filled(
                    tooltip: 'Favoritar',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.roxo,
                      minimumSize: const Size(44, 44),
                    ),
                    onPressed: onFavorito,
                    isSelected: favorito,
                    selectedIcon: const Icon(Icons.favorite),
                    icon: const Icon(Icons.favorite_border),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produto.categoria.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  color: AppColors.textoSuave,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                produto.nome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                produto.precoFormatado,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.roxo,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAdicionar,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(44, 44),
                  ),
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
