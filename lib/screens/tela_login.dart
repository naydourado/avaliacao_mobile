import 'package:flutter/material.dart';
import '../services/autenticacao_service.dart';
import '../theme/app_colors.dart';

class TelaLogin extends StatefulWidget {
  final void Function(String perfil, String chaveAdmin) onEntrar;

  const TelaLogin({super.key, required this.onEntrar});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();
  final autenticacaoService = AutenticacaoService();
  bool entrando = false;
  bool mostrarSenha = false;
  String? erro;

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    autenticacaoService.cliente.close();
    super.dispose();
  }

  Future<void> entrar() async {
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text;
    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => erro = 'Preencha usuário e senha.');
      return;
    }

    setState(() {
      entrando = true;
      erro = null;
    });
    try {
      final conta = await autenticacaoService.entrar(usuario, senha);
      if (!mounted) return;
      // A chave só fica em memória, para as ações administrativas.
      widget.onEntrar(conta.perfil, conta.administrador ? senha : '');
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.cookie_outlined,
                        size: 64, color: AppColors.roxo),
                    const SizedBox(height: 12),
                    const Text('Sweets by Isa',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold,
                          color: AppColors.roxo)),
                    const SizedBox(height: 6),
                    const Text('Entre para acessar nosso cardápio',
                      textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextField(
                      controller: usuarioController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuário', prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: senhaController,
                      obscureText: !mostrarSenha,
                      onSubmitted: (_) => entrar(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                          onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
                          icon: Icon(mostrarSenha ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ),
                    if (erro != null) ...[
                      const SizedBox(height: 12),
                      Text(erro!, style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: entrando ? null : entrar,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: entrando
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Acesso de cliente ou administradora.\n'
                        'Contas de demonstração descritas no README.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
