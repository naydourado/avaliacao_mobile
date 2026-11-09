import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

EdgeInsets margemPagina(BuildContext context, {double larguraMaxima = 1080}) {
  final margem = math.max(
    20.0,
    (MediaQuery.sizeOf(context).width - larguraMaxima) / 2,
  );
  return EdgeInsets.fromLTRB(margem, 24, margem, 32);
}

class PaginaConteudo extends StatelessWidget {
  final List<Widget> children;
  final double larguraMaxima;
  const PaginaConteudo({
    super.key,
    required this.children,
    this.larguraMaxima = 1080,
  });
  @override
  Widget build(BuildContext context) => ListView(
    padding: margemPagina(context, larguraMaxima: larguraMaxima),
    children: children,
  );
}

class CabecalhoPagina extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String? etiqueta;
  const CabecalhoPagina({
    super.key,
    required this.titulo,
    required this.descricao,
    this.etiqueta,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (etiqueta != null) ...[
          Text(
            etiqueta!.toUpperCase(),
            style: const TextStyle(
              color: AppColors.roxo,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.roxo,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          descricao,
          style: const TextStyle(color: AppColors.textoSuave, height: 1.5),
        ),
      ],
    ),
  );
}

class AvisoLoja extends StatelessWidget {
  final IconData icone;
  final String texto;
  const AvisoLoja({super.key, required this.icone, required this.texto});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.lavanda,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: AppColors.roxo, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: AppColors.roxo,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.lavanda,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: AppColors.roxo, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.roxo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          descricao,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textoSuave, height: 1.5),
        ),
      ],
    ),
  );
}

class ImagemDoce extends StatelessWidget {
  final String caminho;
  final double tamanho;
  const ImagemDoce({super.key, required this.caminho, this.tamanho = 72});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.asset(
      caminho,
      width: tamanho,
      height: tamanho,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: tamanho,
        height: tamanho,
        color: AppColors.lavanda,
        child: const Icon(Icons.cookie_outlined, color: AppColors.roxo),
      ),
    ),
  );
}
