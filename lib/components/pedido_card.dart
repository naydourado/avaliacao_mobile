import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../theme/app_colors.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final Widget? acao;
  final bool mostrarCodigo;
  const PedidoCard({
    super.key,
    required this.pedido,
    this.acao,
    this.mostrarCodigo = true,
  });

  @override
  Widget build(BuildContext context) {
    final pronto = pedido.status == 'PRONTO' || pedido.status == 'ENTREGUE';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${pedido.id}',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.roxo,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: pronto ? AppColors.amarelo : AppColors.lavanda,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Status: ${pedido.statusFormatado}',
                  style: const TextStyle(
                    color: AppColors.roxo,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Nome: ${pedido.nomeCliente}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Pagamento: ${pedido.pagamento}',
                style: const TextStyle(
                  color: AppColors.textoSuave,
                  fontSize: 13,
                ),
              ),
              const Divider(),
              for (final item in pedido.itens)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${item.quantidade}x',
                          style: const TextStyle(
                            color: AppColors.roxo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item.nome)),
                    ],
                  ),
                ),
              if (pedido.observacoes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Obs.: ${pedido.observacoes}',
                  style: const TextStyle(color: AppColors.textoSuave),
                ),
              ],
              const Divider(),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Total do pedido',
                    style: TextStyle(color: AppColors.textoSuave),
                  ),
                  Text(
                    pedido.totalFormatado,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.roxo,
                    ),
                  ),
                ],
              ),
              if (mostrarCodigo) ...[
                const SizedBox(height: 16),
                SelectableText(
                  'Código: ${pedido.codigo}',
                  style: const TextStyle(
                    color: AppColors.textoSuave,
                    fontSize: 12,
                  ),
                ),
              ],
              if (acao != null) ...[const SizedBox(height: 24), acao!],
            ],
          ),
        ),
      ),
    );
  }
}
