import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../components/app_widgets.dart';
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
    if (entrando) return;
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
      widget.onEntrar(conta.perfil, conta.administrador ? senha : '');
    } catch (e) {
      if (mounted) {
        setState(() => erro = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => entrando = false);
    }
  }

  Widget formulario() => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CabecalhoPagina(
            etiqueta: 'BOAS-VINDAS',
            titulo: 'Seu momento doce\ncomeça aqui.',
            descricao: 'Entre para acessar nosso cardápio.',
          ),
          TextField(
            controller: usuarioController,
            enabled: !entrando,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Usuário',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: senhaController,
            enabled: !entrando,
            obscureText: !mostrarSenha,
            onSubmitted: (_) => entrar(),
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
                icon: Icon(
                  mostrarSenha
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          if (erro != null) ...[
            const SizedBox(height: 16),
            Text(
              erro!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: entrando ? null : entrar,
            child: entrando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Entrar'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Acesso de cliente ou administradora.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textoSuave),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, tamanho) {
          final amplo = tamanho.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, tamanho.maxHeight - 48),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: amplo
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: _ApresentacaoLogin(amplo: true),
                            ),
                            const SizedBox(width: 48),
                            SizedBox(width: 420, child: formulario()),
                          ],
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            children: [
                              const _ApresentacaoLogin(amplo: false),
                              const SizedBox(height: 20),
                              formulario(),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _ApresentacaoLogin extends StatelessWidget {
  final bool amplo;
  const _ApresentacaoLogin({required this.amplo});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(amplo ? 40 : 24),
    decoration: BoxDecoration(
      color: AppColors.amarelo,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cookie_outlined, size: 40, color: AppColors.roxo),
        const SizedBox(height: 18),
        Text(
          'Sweets by Isa',
          style: TextStyle(
            fontSize: amplo ? 42 : 32,
            height: 1.1,
            color: AppColors.roxo,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pequenos doces.\nBons momentos.',
          style: TextStyle(fontSize: 18, height: 1.4, color: AppColors.roxo),
        ),
        if (amplo) ...[
          const SizedBox(height: 32),
          const Center(
            child: ImagemDoce(
              caminho: 'assets/images/cookie_recheado.png',
              tamanho: 240,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hortolândia e região • Retirada na faculdade',
            style: TextStyle(fontSize: 12, color: AppColors.roxo),
          ),
        ],
      ],
    ),
  );
}
