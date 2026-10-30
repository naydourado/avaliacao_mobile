import 'package:flutter/material.dart';
import '../services/produto_service.dart';
import '../services/pedido_service.dart';
import '../theme/app_colors.dart';
import 'tela_gestao.dart';
import 'tela_gestao_pedidos.dart';

// Painel inicial da administradora. Cada opção abre uma tela específica.
// O cliente comum não recebe esta página na barra de navegação.
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

  Future<void> abrirProdutos(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaGestao(
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
        builder: (context) => TelaGestaoPedidos(
          pedidoService: pedidoService,
          chave: chaveAdmin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Administração', style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: AppColors.roxo,
                )),
                const SizedBox(height: 6),
                const Text('Escolha o que deseja gerenciar na loja.'),
                const SizedBox(height: 18),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.inventory_2_outlined, color: AppColors.roxo),
                          SizedBox(width: 10),
                          Text('Produtos', style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold,
                          )),
                        ]),
                        const SizedBox(height: 10),
                        Text('$quantidadeProdutos produtos no cardápio.'),
                        const Text('Cadastrar novos doces, consultar a lista, '
                            'editar preços ou excluir produtos.'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => abrirProdutos(context),
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Gerenciar produtos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.receipt_long_outlined, color: AppColors.roxo),
                          SizedBox(width: 10),
                          Text('Pedidos recebidos', style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold,
                          )),
                        ]),
                        const SizedBox(height: 10),
                        const Text('Consultar pedidos dos clientes e alterar '
                            'o status: recebido, em preparo, pronto, '
                            'entregue ou cancelado.'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => abrirPedidos(context),
                            icon: const Icon(Icons.list_alt_outlined),
                            label: const Text('Gerenciar pedidos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(children: [
                  Icon(Icons.lock_outline, size: 17, color: AppColors.roxo),
                  SizedBox(width: 7),
                  Expanded(child: Text(
                    'Área exclusiva da administradora. '
                    'As alterações são salvas na API.',
                    style: TextStyle(fontSize: 12),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
