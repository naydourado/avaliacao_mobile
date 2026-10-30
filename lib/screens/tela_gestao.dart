import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import '../theme/app_colors.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> abrirFormulario({Produto? produto}) async {
    if (salvando) return;
    if (widget.chaveAdmin.isEmpty) {
      mostrarMensagem('Faça login como administradora para continuar.');
      return;
    }

    final nome = TextEditingController(text: produto?.nome ?? '');
    final categoria = TextEditingController(text: produto?.categoria ?? '');
    final preco = TextEditingController(
      text: produto == null ? '' : produto.preco.toStringAsFixed(2),
    );

    final dados = await showDialog<List<dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(produto == null ? 'Cadastrar doce' : 'Editar doce'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nome,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              TextField(
                controller: preco,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = double.tryParse(
                preco.text.trim().replaceAll(',', '.'),
              );
              if (nome.text.trim().isEmpty || categoria.text.trim().isEmpty ||
                  valor == null || valor <= 0 || !valor.isFinite) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Preencha os dados corretamente.')),
                );
                return;
              }
              Navigator.pop(dialogContext, [
                nome.text.trim(), categoria.text.trim(), valor,
              ]);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    nome.dispose();
    categoria.dispose();
    preco.dispose();
    if (!mounted || dados == null) return;

    setState(() => salvando = true);
    try {
      if (produto == null) {
        await widget.produtoService.criarProduto(
          dados[0] as String, dados[1] as String,
          dados[2] as double, widget.chaveAdmin,
        );
      } else {
        await widget.produtoService.editarProduto(
          produto, dados[0] as String, dados[1] as String,
          dados[2] as double, widget.chaveAdmin,
        );
      }
      await carregarProdutos();
      await widget.onAlterado();
      if (mounted) {
        mostrarMensagem(produto == null ? 'Produto cadastrado!' : 'Produto atualizado!');
      }
    } catch (e) {
      if (mounted) mostrarMensagem(e.toString().replaceFirst('Exception: ', ''));
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
      await widget.produtoService.excluirProduto(
        produto.id, widget.chaveAdmin,
      );
      await carregarProdutos();
      await widget.onAlterado();
      if (mounted) mostrarMensagem('Produto excluído!');
    } catch (e) {
      if (mounted) mostrarMensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar produtos')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.amarelo,
        foregroundColor: AppColors.roxo,
        onPressed: salvando ? null : () => abrirFormulario(),
        label: const Text('Novo doce'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produtos cadastrados (${produtos.length})',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('As alterações são enviadas à API e salvas no banco de dados.'),
            const SizedBox(height: 12),
            const Text('Use + Novo doce para cadastrar. Toque no lápis '
                'para editar ou na lixeira para excluir.',
                style: TextStyle(color: AppColors.roxo)),
            const SizedBox(height: 8),
            if (salvando) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : erro != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Erro: $erro'),
                              TextButton(
                                onPressed: carregarProdutos,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : produtos.isEmpty
                          ? const Center(child: Text('Nenhum produto cadastrado.'))
                          : ListView.builder(
                              itemCount: produtos.length,
                              itemBuilder: (context, index) {
                                final produto = produtos[index];
                                return Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        produto.imagem,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.cookie),
                                      ),
                                    ),
                                    title: Text(produto.nome),
                                    subtitle: Text(
                                      '${produto.categoria} • ${produto.precoFormatado}',
                                    ),
                                    trailing: Wrap(
                                      spacing: 0,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          onPressed: salvando
                                              ? null
                                              : () => abrirFormulario(produto: produto),
                                          icon: const Icon(Icons.edit_outlined,
                                              color: AppColors.roxo),
                                        ),
                                        IconButton(
                                          tooltip: 'Excluir',
                                          onPressed: salvando
                                              ? null
                                              : () => confirmarExclusao(produto),
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
