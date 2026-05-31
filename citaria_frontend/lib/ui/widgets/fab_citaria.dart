import 'package:flutter/material.dart';

/// Botón flotante común de Citaria.
///
/// Centraliza el estilo visual del FAB.
class FabCitaria extends StatelessWidget {
  const FabCitaria({
    super.key,
    required this.icono,
    required this.tooltip,
    required this.onPressed,
    this.heroTag,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback onPressed;

  /// Tag opcional para evitar conflictos si una pantalla tuviera más de un FAB.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: tooltip,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      onPressed: onPressed,
      child: Icon(icono),
    );
  }
}
