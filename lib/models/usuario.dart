class Usuario {
  final String nome;
  final String perfil;

  const Usuario({required this.nome, required this.perfil});

  bool get administrador => perfil == 'ADMIN';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nome: json['usuario'] as String,
      perfil: json['perfil'] as String,
    );
  }
}
