import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:flutter/material.dart';

/// Banda de error con mensaje y opcionalmente botón de reintento.
class AvisoError extends StatelessWidget {
  const AvisoError({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  final String mensaje;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (onReintentar == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: espaciado.radioCard,
        ),
        child: Text(
          mensaje,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: espaciado.radioCard,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
