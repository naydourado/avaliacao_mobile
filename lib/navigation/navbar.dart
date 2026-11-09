import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import '../services/pedido_service.dart';
import '../screens/tela_home.dart';
import '../screens/tela_carrinho.dart';
import '../screens/tela_favoritos.dart';
import '../screens/tela_admin.dart';
import '../screens/tela_pedidos.dart';
import '../screens/tela_feriados.dart';
import '../theme/app_colors.dart';

class NavBar extends StatefulWidget {
  final String perfil;
  final String chaveAdmin;
  final VoidCallback onSair;
  final ProdutoService? servicoProdutos;
  final PedidoService? servicoPedidos;

  const NavBar({
    super.key,
    required this.perfil,
    required this.chaveAdmin,
    required this.onSair,
    this.servicoProdutos,
    this.servicoPedidos,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late final ProdutoService produtoService =
      widget.servicoProdutos ?? ProdutoService();
  late final PedidoService pedidoService =
      widget.servicoPedidos ?? PedidoService();
  int indexAtual = 0;
  Set<int> favoritos = {};
  Map<int, int> carrinho = {};
  List<Produto> produtos = [];
  bool carregando = true;
  String? erro;

  // Mantém o histórico antigo do cliente e separa as compras da administradora.
  String get chavePedidos =>
      widget.perfil == 'ADMIN' ? 'pedidos_codigos_admin' : 'pedidos_codigos';

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final lista = await produtoService.listarProdutos();
      if (!mounted) return;
      setState(() {
        produtos = lista;
        final ids = lista.map((p) => p.id).toSet();
        carrinho.removeWhere((id, quantidade) => !ids.contains(id));
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

  Future<void> carregarFavoritos() async {
    final preferencias = await SharedPreferences.getInstance();
    final ids = preferencias.getStringList('favoritos') ?? [];
    if (!mounted) return;
    setState(() {
      favoritos = ids.map((id) => int.tryParse(id)).whereType<int>().toSet();
    });
  }

  Future<void> salvarFavoritos() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setStringList(
      'favoritos',
      favoritos.map((id) => id.toString()).toList(),
    );
  }

  void mudarIndex(int novoIndex) => setState(() => indexAtual = novoIndex);

  void alternarFavorito(int id) {
    setState(() {
      if (favoritos.contains(id)) {
        favoritos.remove(id);
      } else {
        favoritos.add(id);
      }
    });
    salvarFavoritos();
  }

  void adicionarAoCarrinho(Produto produto) {
    aumentarQuantidade(produto.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produto.nome} adicionado ao carrinho!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void aumentarQuantidade(int id) {
    setState(() => carrinho[id] = (carrinho[id] ?? 0) + 1);
  }

  void diminuirQuantidade(int id) {
    final atual = carrinho[id] ?? 0;
    setState(() {
      if (atual <= 1) {
        carrinho.remove(id);
      } else {
        carrinho[id] = atual - 1;
      }
    });
  }

  Future<void> confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você voltará à tela de login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (sair == true && mounted) widget.onSair();
  }

  void pedidoFinalizado() {
    setState(() {
      carrinho.clear();
      indexAtual = 3;
    });
  }

  void abrirFeriados() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaFeriados()),
    );
  }

  @override
  void dispose() {
    pedidoService.cliente.close();
    produtoService.cliente.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final administrador = widget.perfil == 'ADMIN';
    final paginas = [
      TelaHome(
        produtos: produtos,
        favoritos: favoritos,
        onAdicionar: adicionarAoCarrinho,
        onFavorito: alternarFavorito,
        mostrarFavoritos: !administrador,
      ),
      if (administrador)
        TelaAdmin(
          quantidadeProdutos: produtos.length,
          produtoService: produtoService,
          pedidoService: pedidoService,
          chaveAdmin: widget.chaveAdmin,
          onProdutosAlterados: carregarProdutos,
        )
      else
        TelaFavoritos(
          produtos: produtos,
          favoritos: favoritos,
          onAdicionar: adicionarAoCarrinho,
          onFavorito: alternarFavorito,
        ),
      TelaCarrinho(
        produtos: produtos,
        carrinho: carrinho,
        onAdicionar: aumentarQuantidade,
        onRemover: diminuirQuantidade,
        pedidoService: pedidoService,
        chavePedidos: chavePedidos,
        onPedidoFinalizado: pedidoFinalizado,
      ),
      TelaPedidos(pedidoService: pedidoService, chavePedidos: chavePedidos),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cookie_outlined, color: AppColors.roxo, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sweets by Isa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: abrirFeriados,
            tooltip: 'Consultar feriados (BrasilAPI)',
            icon: const Icon(Icons.event_outlined),
          ),
          IconButton(
            onPressed: carregarProdutos,
            tooltip: 'Atualizar cardápio',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: confirmarSaida,
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: AppColors.roxo),
                    const SizedBox(height: 12),
                    const Text('Não foi possível carregar o cardápio.'),
                    const SizedBox(height: 8),
                    Text(erro!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: carregarProdutos,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : paginas[indexAtual],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borda)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: BottomNavigationBar(
              currentIndex: indexAtual,
              onTap: mudarIndex,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.roxo,
              unselectedItemColor: AppColors.textoSuave,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Cardápio',
                ),
                if (administrador)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Admin',
                  )
                else
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Favoritos',
                  ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: carrinho.isNotEmpty,
                    backgroundColor: AppColors.amarelo,
                    textColor: AppColors.roxo,
                    label: Text(
                      '${carrinho.values.fold<int>(0, (total, qtd) => total + qtd)}',
                    ),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  activeIcon: const Icon(Icons.shopping_bag),
                  label: 'Carrinho',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long_outlined),
                  activeIcon: const Icon(Icons.receipt_long),
                  label: administrador ? 'Meus pedidos' : 'Pedidos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
