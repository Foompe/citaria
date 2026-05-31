import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Cabecera compartida por los 5 pasos del wizard de reserva
class CabeceraWizard extends StatelessWidget {
  const CabeceraWizard({
    super.key,
    required this.pasoActual,
    required this.totalPasos,
    required this.titulo,
  });

  /// Índice 0-based del paso actual (0..4).
  final int pasoActual;

  /// Número total de pasos (siempre 5).
  final int totalPasos;

  /// Título descriptivo que se muestra bajo.
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            espaciado.padX,
            8,
            espaciado.padX,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila superior
              Row(
                children: [
                  Semantics(
                    label: 'Volver al paso anterior',
                    child: Tooltip(
                      message: 'Volver',
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: espaciado.radioPill,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Paso ${pasoActual + 1} de $totalPasos',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 10),

              // Stepper lineal
              Row(
                children: List.generate(totalPasos, (index) {
                  final esCompletadoOActual = index <= pasoActual;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < totalPasos - 1 ? 4 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: esCompletadoOActual
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: espaciado.radioPill,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Título del paso
              Text(
                titulo,
                style: textTheme.displayLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
