class ItemPedido {
  final String nome;
  final int quantidade;
  final double precoUnitario;

  ItemPedido({
    required this.nome,
    required this.quantidade,
    required this.precoUnitario,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      nome: json['produto_nome'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
      precoUnitario: (json['preco_unitario'] as num).toDouble(),
    );
  }
}

class Pedido {
  final int id;
  final String codigo;
  final String nomeCliente;
  final String pagamento;
  final String status;
  final String observacoes;
  final String criadoEm;
  final double total;
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.codigo,
    required this.nomeCliente,
    required this.pagamento,
    required this.status,
    required this.observacoes,
    required this.criadoEm,
    required this.total,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: (json['id'] as num).toInt(),
      codigo: json['codigo'] as String,
      nomeCliente: json['nome_cliente'] as String,
      pagamento: json['pagamento'] as String,
      status: json['status'] as String,
      observacoes: json['observacoes'] as String,
      criadoEm: json['criado_em'] as String,
      total: (json['total'] as num).toDouble(),
      itens: (json['itens'] as List)
          .map((item) => ItemPedido.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String get totalFormatado =>
      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

  String get statusFormatado {
    if (status == 'EM_PREPARO') return 'Em preparo';
    if (status == 'PRONTO') return 'Pronto para retirada';
    if (status == 'ENTREGUE') return 'Entregue';
    if (status == 'CANCELADO') return 'Cancelado';
    return 'Recebido';
  }
}
