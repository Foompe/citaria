import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Cabecera compartida por los 5 pasos del wizard de reserva.
///
/// Muestra: botón atrás + indicador "Paso X de 5" + stepper lineal + título.
/// Implementa [PreferredSizeWidget] para usarse como [AppBar] en el Scaffold.
class CabeceraWizard extends StatelessWidget implements PreferredSizeWidget {
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

  /// Título descriptivo que se muestra bajo el stepper.
  final String titulo;

  // Altura real del contenido:
  // 40 (fila atrás) + 10 (gap) + 4 (stepper) + 12 (gap) + 24 (título)
  // + 16 (padding top) + 8 (padding bottom) + statusBar gestionado por
  // Scaffold. Se declara generosa para evitar overflow en cualquier fuente.
  static const double _alturaContenido = 120;

  @override
  Size get preferredSize => const Size.fromHeight(_alturaContenido);

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final topPadding  = MediaQuery.of(context).padding.top;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(
        espaciado.padX,
        topPadding + 8,
        espaciado.padX,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fila superior: atrás + indicador + equilibrio ────────────────
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

          // ── Stepper lineal ───────────────────────────────────────────────
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

          // ── Título del paso ──────────────────────────────────────────────
          Text(
            titulo,
            style: textTheme.displayLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}