import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Chip seleccionable para habilidades en formularios de empleado y servicio.
///
/// El estado activo/inactivo es responsabilidad del padre — este widget
/// es stateless.
class ChipHabilidad extends StatelessWidget {
  const ChipHabilidad({
    super.key,
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: espaciado.radioPill,
          border: seleccionado
              ? null
              : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          etiqueta,
          style: textTheme.labelSmall?.copyWith(
            color: seleccionado
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}