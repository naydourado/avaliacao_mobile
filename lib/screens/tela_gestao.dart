import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import '../theme/app_colors.dart';
import '../components/app_widgets.dart';

class TelaGestao extends StatefulWidget {
  final ProdutoService produtoService;
  final String chaveAdmin;
  final Future<void> Function() onAlterado;

  const TelaGestao({
    super.key,
    required this.produtoService,
    required this.chaveAdmin,
    required this.onAlterado,
  });

  @override
  State<TelaGestao> createState() => _TelaGestaoState();
}

class _TelaGestaoState extends State<TelaGestao> {
  List<Produto> produtos = [];
  bool carregando = true;
  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final lista = await widget.produtoService.listarProdutos();
      if (!mounted) return;
      setState(() {
        produtos = lista;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> abrirFormulario({Produto? produto}) async {
    if (salvando) return;
    if (widget.chaveAdmin.isEmpty) {
      mostrarMensagem('Faça login como administradora para continuar.');
      return;
    }

    final dados =
        await showDialog<({String nome, String categoria, double preco})>(
          context: context,
          builder: (dialogContext) => _FormularioProduto(produto: produto),
        );
    if (!mounted || dados == null) return;

    setState(() => salvando = true);
    try {
      if (produto == null) {
        await widget.produtoService.criarProduto(
          dados.nome,
          dados.categoria,
          dados.preco,
          widget.chaveAdmin,
        );
      } else {
        await widget.produtoService.editarProduto(
          produto,
          dados.nome,
          dados.categoria,
          dados.preco,
          widget.chaveAdmin,
        );
      }
      await carregarProdutos();
      await widget.onAlterado();
      if (mounted) {
        mostrarMensagem(
          produto == null ? 'Produto cadastrado!' : 'Produto atualizado!',
        );
      }
    } catch (e) {
      if (mounted) {
        mostrarMensagem(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> confirmarExclusao(Produto produto) async {
    if (salvando) return;
    if (widget.chaveAdmin.isEmpty) {
      mostrarMensagem('Faça login como administradora para continuar.');
      return;
    }
    final resposta = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('Deseja excluir ${produto.nome} permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || resposta != true) return;
    setState(() => salvando = true);
    try {
      await widget.produtoService.excluirProduto(produto.id, widget.chaveAdmin);
      await carregarProdutos();
      await widget.onAlterado();
      if (mounted) mostrarMensagem('Produto excluído!');
    } catch (e) {
      if (mounted) {
        mostrarMensagem(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gerenciar produtos')),
    body: PaginaConteudo(
      larguraMaxima: 900,
      children: [
        CabecalhoPagina(
          etiqueta: 'O SABOR DA SUA LOJA',
          titulo: 'Produtos cadastrados (${produtos.length})',
          descricao: 'Deixe o cardápio com a cara da Sweets by Isa.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: salvando ? null : () => abrirFormulario(),
            icon: const Icon(Icons.add),
            label: const Text('Novo doce'),
          ),
        ),
        const SizedBox(height: 24),
        if (salvando)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(),
          ),
        if (carregando)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (erro != null) ...[
          AvisoLoja(icone: Icons.error_outline, texto: erro!),
          TextButton(
            onPressed: carregarProdutos,
            child: const Text('Tentar novamente'),
          ),
        ] else if (produtos.isEmpty)
          const EstadoVazio(
            icone: Icons.cookie_outlined,
            titulo: 'Nenhum produto cadastrado.',
            descricao:
                'Toque em Novo doce para dar o primeiro sabor ao cardápio.',
          )
        else
          for (final produto in produtos)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImagemDoce(caminho: produto.imagem),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produto.categoria.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                    color: AppColors.textoSuave,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  produto.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  produto.precoFormatado,
                                  style: const TextStyle(
                                    color: AppColors.roxo,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: salvando
                                ? null
                                : () => abrirFormulario(produto: produto),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.roxo,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            onPressed: salvando
                                ? null
                                : () => confirmarExclusao(produto),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}

// Os controles existem até o fim da animação de fechamento do diálogo.
class _FormularioProduto extends StatefulWidget {
  final Produto? produto;
  const _FormularioProduto({this.produto});

  @override
  State<_FormularioProduto> createState() => _FormularioProdutoState();
}

class _FormularioProdutoState extends State<_FormularioProduto> {
  late final nome = TextEditingController(text: widget.produto?.nome ?? '');
  late final categoria = TextEditingController(
    text: widget.produto?.categoria ?? '',
  );
  late final preco = TextEditingController(
    text: widget.produto?.preco.toStringAsFixed(2) ?? '',
  );
  String? erro;

  @override
  void dispose() {
    nome.dispose();
    categoria.dispose();
    preco.dispose();
    super.dispose();
  }

  void salvar() {
    final valor = double.tryParse(preco.text.trim().replaceAll(',', '.'));
    if (nome.text.trim().isEmpty ||
        categoria.text.trim().isEmpty ||
        valor == null ||
        valor <= 0 ||
        !valor.isFinite) {
      setState(() => erro = 'Preencha os dados corretamente.');
      return;
    }
    Navigator.pop(context, (
      nome: nome.text.trim(),
      categoria: categoria.text.trim(),
      preco: valor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.produto == null ? 'Cadastrar doce' : 'Editar doce'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nome,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: categoria,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            TextField(
              controller: preco,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
            ),
            if (erro != null)
              Text(erro!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: salvar, child: const Text('Salvar')),
      ],
    );
  }
}
