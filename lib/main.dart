import 'package:flutter/material.dart';
import 'navigation/navbar.dart';
import 'screens/tela_login.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? perfil;
  String chaveAdmin = '';

  void entrar(String perfilRecebido, String chave) {
    setState(() {
      perfil = perfilRecebido;
      chaveAdmin = chave;
    });
  }

  void sair() {
    setState(() {
      perfil = null;
      chaveAdmin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sweets by Isa',
      theme: AppTheme.claro,
      home: perfil == null
          ? TelaLogin(onEntrar: entrar)
          : NavBar(perfil: perfil!, chaveAdmin: chaveAdmin, onSair: sair),
    );
  }
}
