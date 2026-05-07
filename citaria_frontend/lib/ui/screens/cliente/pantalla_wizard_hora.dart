import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';

// TODO: slots de API — franjas de 15 min desde disponibilidad real.
/// Slots bloqueados hardcodeados de ejemplo.
const Set<String> _slotsBloqueados = {
  '09:30', '10:00', '11:15', '12:00', '12:30',
};

/// Genera slots de 09:00 a 13:30 cada 15 minutos.
List<String> _generarSlots() {
  final slots  = <String>[];
  var hora     = 9;
  var minuto   = 0;
  while (hora < 13 || (hora == 13 && minuto <= 30)) {
    slots.add(
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}',
    );
    minuto += 15;
    if (minuto >= 60) {
      minuto = 0;
      hora++;
    }
  }
  return slots;
}

/// Paso 4 del wizard de reserva: selección de hora.
///
/// Ruta: /nueva-reserva/hora
class PantallaWizardHora extends StatefulWidget {
  const PantallaWizardHora({super.key});

  @override
  State<PantallaWizardHora> createState() => _PantallaWizardHoraState();
}

class _PantallaWizardHoraState extends State<PantallaWizardHora> {
  String? _slotSeleccionado;
  final List<String> _slots = _generarSlots();

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraWizard(
        pasoActual: 3,
        totalPasos: 5,
        titulo: 'Elige la hora',
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.padX,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Chip fecha seleccionada + duración ─────────────────────────
            Row(
              children: [
                // TODO: mostrar fecha real seleccionada desde estado wizard
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: espaciado.radioPill,
                  ),
                  child: Text(
                    'Mar 21 abr',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // TODO: mostrar duración total de servicios seleccionados
                Text('· 90 min', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 20),

            // ── Grid de slots ─────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((slot) {
                final bloqueado    = _slotsBloqueados.contains(slot);
                final seleccionado = _slotSeleccionado == slot;

                final Color fondo;
                final Color textoColor;
                BoxBorder? borde;

                if (seleccionado) {
                  fondo      = colorScheme.primary;
                  textoColor = colorScheme.onPrimary;
                } else if (bloqueado) {
                  fondo      = colorScheme.outline.withOpacity(0.1);
                  textoColor = colorScheme.outline.withOpacity(0.4);
                } else {
                  fondo      = Colors.transparent;
                  textoColor = colorScheme.onSurface;
                  borde      = Border.all(
                    color: colorScheme.outline.withOpacity(0.4),
                  );
                }

                return GestureDetector(
                  onTap: bloqueado
                      ? null
                      : () => setState(() => _slotSeleccionado = slot),
                  child: Container(
                    width: 80,
                    height: 44,
                    decoration: BoxDecoration(
                      color: fondo,
                      border: borde,
                      borderRadius: espaciado.radioBoton,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slot,
                          style: textTheme.bodyMedium?.copyWith(
                            color: textoColor,
                          ),
                        ),
                        if (bloqueado) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.lock, size: 10, color: textoColor),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Nota informativa ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: espaciado.radioCard,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Las franjas con candado no están disponibles',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _slotSeleccionado != null
                ? () => GestorNavegacion.irAWizardConfirmar(context)
                : null,
            child: const Text('Siguiente'),
          ),
        ),
      ),
    );
  }
}