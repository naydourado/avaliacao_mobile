import 'package:flutter/material.dart';
import '../components/app_widgets.dart';
import '../components/grade_produtos.dart';
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
  String? categoria;

  @override
  Widget build(BuildContext context) {
    final categorias = widget.produtos.map((p) => p.categoria).toSet().toList();
    final selecionada = categorias.contains(categoria) ? categoria : null;
    final encontrados = widget.produtos
        .where(
          (p) =>
              p.nome.toLowerCase().contains(pesquisa.trim().toLowerCase()) &&
              (selecionada == null || p.categoria == selecionada),
        )
        .toList();
    final margem = margemPagina(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(margem.left, 12, margem.right, 0),
          sliver: SliverList.list(
            children: [
              const _DestaqueCardapio(),
              const SizedBox(height: 24),
              TextField(
                onChanged: (valor) => setState(() => pesquisa = valor),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Pesquisar docinhos...',
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final opcao in <String?>[null, ...categorias])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(opcao ?? 'Todos'),
                          selected: selecionada == opcao,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: selecionada == opcao
                                ? Colors.white
                                : AppColors.roxo,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => categoria = opcao),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const CabecalhoPagina(
                titulo: 'Nosso cardápio',
                descricao: 'Escolha o doce que combina com o seu dia.',
              ),
            ],
          ),
        ),
        if (encontrados.isEmpty)
          const SliverToBoxAdapter(
            child: EstadoVazio(
              icone: Icons.search_off,
              titulo: 'Nenhum doce encontrado.',
              descricao: 'Experimente outro nome ou categoria.',
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(margem.left, 0, margem.right, 96),
            sliver: GradeProdutos(
              produtos: encontrados,
              favoritos: widget.favoritos,
              onAdicionar: widget.onAdicionar,
              onFavorito: widget.onFavorito,
              mostrarFavoritos: widget.mostrarFavoritos,
            ),
          ),
      ],
    );
  }
}

class _DestaqueCardapio extends StatelessWidget {
  const _DestaqueCardapio();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, tamanho) {
      final amplo = tamanho.maxWidth > 650;
      return Container(
        padding: EdgeInsets.all(amplo ? 32 : 24),
        decoration: BoxDecoration(
          color: AppColors.amarelo,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FEITO PARA ADOÇAR',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roxo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Um docinho\nalegra o dia!',
                    style: TextStyle(
                      fontSize: amplo ? 40 : 28,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      color: AppColors.roxo,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Um carinho em cada mordida.',
                    style: TextStyle(color: AppColors.roxo, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: AppColors.roxo,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retirada na faculdade',
                          style: TextStyle(fontSize: 12, color: AppColors.roxo),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (tamanho.maxWidth >= 340) ...[
              SizedBox(width: amplo ? 32 : 12),
              Transform.rotate(
                angle: -0.06,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.fundo,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ImagemDoce(
                    caminho: 'assets/images/cookie_recheado.png',
                    tamanho: amplo ? 200 : 94,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
