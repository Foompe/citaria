import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';
import 'package:flutter/material.dart';

/// Sección "HORARIO SEMANAL" con label, card y filas de días.
///
/// Pasa soloLectura true para deshabilitar la interacción (AbsorbPointer).
class SeccionHorarioSemanal extends StatelessWidget {
  const SeccionHorarioSemanal({
    super.key,
    required this.filas,
    this.soloLectura = false,
  });

  final List<FilaDiaHorario> filas;
  final bool soloLectura;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget card = Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Column(
        children: [
          for (int i = 0; i < filas.length; i++) ...[
            filas[i],
            if (i < filas.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HORARIO SEMANAL',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        if (filas.isEmpty)
          Text(
            'Sin horario configurado',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          )
        else if (soloLectura)
          AbsorbPointer(child: card)
        else
          card,
      ],
    );
  }
}
