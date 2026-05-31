import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Etiqueta decorativa para categorías y habilidades dentro del wizard de reserva.
class EtiquetaWizard extends StatelessWidget {
  const EtiquetaWizard({super.key, required this.etiqueta});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        etiqueta,
        style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
      ),
    );
  }
}
