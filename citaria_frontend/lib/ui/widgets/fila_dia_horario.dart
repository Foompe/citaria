import 'package:flutter/material.dart';

/// Fila de día con Switch de activación y texto de horario.
///
/// Se usa dentro de una Card lista sin padding en las pantallas
/// de horarios: PantallaAdminNuevoEmpleado, PantallaAdminDetalleEmpleado
/// y PantallaAdminHorarios.
///
/// El padre es responsable de envolver y separar entre ellas.
///
class FilaDiaHorario extends StatelessWidget {
  const FilaDiaHorario({
    super.key,
    required this.dia,
    required this.activo,
    required this.horario,
    required this.onChanged,
  });

  final String dia;
  final bool activo;

  /// Texto de horario mostrado cuando [activo] es true.
  /// Cuando [activo] es false se muestra "Cerrado" automáticamente.
  final String horario;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Switch(value: activo, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(child: Text(dia, style: textTheme.bodyLarge)),
          Text(
            activo ? horario : 'Cerrado',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
