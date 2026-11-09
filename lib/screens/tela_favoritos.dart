import 'package:flutter/material.dart';
import '../components/app_widgets.dart';
import '../components/grade_produtos.dart';
import '../models/produto.dart';

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
    final margem = margemPagina(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(margem.left, 24, margem.right, 0),
          sliver: const SliverToBoxAdapter(
            child: CabecalhoPagina(
              etiqueta: 'SEUS QUERIDINHOS',
              titulo: 'Meus favoritos',
              descricao: 'Os doces que ganharam um lugar no seu coração.',
            ),
          ),
        ),
        if (lista.isEmpty)
          const SliverToBoxAdapter(
            child: EstadoVazio(
              icone: Icons.favorite_border,
              titulo: 'Seus favoritos moram aqui.',
              descricao: 'Toque no coração para favoritar um doce.',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(margem.left, 0, margem.right, 32),
            sliver: GradeProdutos(
              produtos: lista,
              favoritos: favoritos,
              onAdicionar: onAdicionar,
              onFavorito: onFavorito,
            ),
          ),
      ],
    );
  }
}
