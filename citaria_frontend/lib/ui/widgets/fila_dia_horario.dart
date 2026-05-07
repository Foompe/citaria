import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Fila de día con Switch de activación y texto de horario.
///
/// Se usa dentro de una Card lista sin padding en las pantallas
/// de horarios: PantallaAdminNuevoEmpleado, PantallaAdminDetalleEmpleado
/// y PantallaAdminHorarios.
///
/// El padre es responsable de envolver varias [FilaDiaHorario] en una
/// [Card] con [Column] y separar con [Divider] entre ellas.
///
/// Cuando [activo] es false, muestra "Cerrado" en lugar de [horario].
///
/// Uso:
/// ```dart
/// FilaDiaHorario(
///   dia: 'Lunes',
///   activo: _diasActivos[0],
///   horario: '9:00 – 19:00',
///   onChanged: (v) => setState(() => _diasActivos[0] = v),
/// )
/// ```
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
    final textTheme   = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Switch(
            value: activo,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dia,
              style: textTheme.bodyLarge,
            ),
          ),
          Text(
            activo ? horario : 'Cerrado',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}