class Produto {
  final int id;
  final String nome;
  final String categoria;
  final double preco;
  final String imagem;

  Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.imagem,
  });

  // Converte o JSON recebido da API em um objeto da classe Produto.
  factory Produto.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final nome = json['nome'] as String;
    final categoria = json['categoria'] as String;
    final preco = (json['preco'] as num).toDouble();
    final imagem = json['imagem'] as String;
    // Herança simples: os tipos de doce são subclasses de Produto.
    if (categoria == 'Brownies') {
      return Brownie(id: id, nome: nome, preco: preco, imagem: imagem);
    }
    if (categoria == 'Cookies') {
      return Cookie(id: id, nome: nome, preco: preco, imagem: imagem);
    }
    if (categoria == 'Palhas italianas') {
      return PalhaItaliana(id: id, nome: nome, preco: preco, imagem: imagem);
    }
    return Produto(id: id, nome: nome, categoria: categoria,
      preco: preco, imagem: imagem);
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'preco': preco,
      'imagem': imagem,
    };
  }

  // Diferenca entre linguagens: em Python o if usa indentacao;
  // em Dart, blocos do if, for e das funcoes sao definidos com { }.
  String get precoFormatado {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

// Subclasses do mesmo modelo, sem acrescentar telas ou bibliotecas complexas.
class Brownie extends Produto {
  Brownie({required int id, required String nome,
      required double preco, required String imagem})
      : super(id: id, nome: nome, categoria: 'Brownies',
          preco: preco, imagem: imagem);
}

class Cookie extends Produto {
  Cookie({required int id, required String nome,
      required double preco, required String imagem})
      : super(id: id, nome: nome, categoria: 'Cookies',
          preco: preco, imagem: imagem);
}

class PalhaItaliana extends Produto {
  PalhaItaliana({required int id, required String nome,
      required double preco, required String imagem})
      : super(id: id, nome: nome, categoria: 'Palhas italianas',
          preco: preco, imagem: imagem);
}
