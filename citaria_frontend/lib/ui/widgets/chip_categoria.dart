import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Chip de categoría reutilizable para filtros horizontales.
class ChipCategoria extends StatelessWidget {
  const ChipCategoria({
    super.key,
    required this.etiqueta,
    required this.activo,
  });

  final String etiqueta;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: activo
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: espaciado.radioPill,
      ),
      alignment: Alignment.center,
      child: Text(
        etiqueta,
        textAlign: TextAlign.center,
        style: textTheme.labelSmall?.copyWith(
          color: activo ? colorScheme.onPrimary : colorScheme.onSurface,
          height: 1,
        ),
      ),
    );
  }
}
