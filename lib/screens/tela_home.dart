import 'package:flutter/material.dart';
import '../components/produto_card.dart';
import '../models/produto.dart';
import '../theme/app_colors.dart';

class TelaHome extends StatefulWidget {
  final List<Produto> produtos;
  final Set<int> favoritos;
  final void Function(Produto) onAdicionar;
  final void Function(int) onFavorito;
  final bool mostrarFavoritos;

  const TelaHome({
    super.key,
    required this.produtos,
    required this.favoritos,
    required this.onAdicionar,
    required this.onFavorito,
    this.mostrarFavoritos = true,
  });

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  String pesquisa = '';

  @override
  Widget build(BuildContext context) {
    final encontrados = widget.produtos.where((produto) {
      return produto.nome.toLowerCase().contains(pesquisa.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.amarelo,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Um docinho alegra o dia!',
                  style: TextStyle(
                    color: AppColors.roxo,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text('Sweets by Isa • Hortolândia e região'),
                Text('Vendas e retiradas combinadas na faculdade'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (valor) => setState(() => pesquisa = valor),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Pesquisar docinhos...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nosso cardápio',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.roxo,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: encontrados.isEmpty
                ? const Center(child: Text('Nenhum doce encontrado.'))
                : LayoutBuilder(
                    builder: (context, tamanho) {
                      return GridView.builder(
                        itemCount: encontrados.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisExtent: 265,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final produto = encontrados[index];
                          return ProdutoCard(
                            produto: produto,
                            favorito: widget.favoritos.contains(produto.id),
                            onAdicionar: () => widget.onAdicionar(produto),
                            onFavorito: () => widget.onFavorito(produto.id),
                            mostrarFavorito: widget.mostrarFavoritos,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
