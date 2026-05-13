import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';

// TODO: días disponibles de API — ahora hardcodeados para mayo 2026.
/// Días sin disponibilidad en el mes de ejemplo.
const Set<int> _diasBloqueados = {4, 5, 9, 11, 12, 16, 18, 19, 22, 25, 26};

/// Paso 3 del wizard de reserva: selección de fecha.
///
/// Ruta: /nueva-reserva/fecha
class PantallaWizardFecha extends StatefulWidget {
  const PantallaWizardFecha({super.key});

  @override
  State<PantallaWizardFecha> createState() => _PantallaWizardFechaState();
}

class _PantallaWizardFechaState extends State<PantallaWizardFecha> {
  // TODO: mes inicial desde estado global del wizard
  DateTime _mesActual = DateTime(2026, 5);
  DateTime? _diaSeleccionado;

  static const List<String> _cabeceras = [
    'L', 'M', 'X', 'J', 'V', 'S', 'D',
  ];

  static const List<String> _nombresMes = [
    '',
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  void _mesAnterior() => setState(() {
        _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
        _diaSeleccionado = null;
      });

  void _mesSiguiente() => setState(() {
        _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
        _diaSeleccionado = null;
      });

  bool _esBloqueado(int dia) => _diasBloqueados.contains(dia);

  bool _esHoy(int dia) {
    final hoy = DateTime.now();
    return hoy.year == _mesActual.year &&
        hoy.month == _mesActual.month &&
        hoy.day == dia;
  }

  bool _esSeleccionado(int dia) =>
      _diaSeleccionado?.year == _mesActual.year &&
      _diaSeleccionado?.month == _mesActual.month &&
      _diaSeleccionado?.day == dia;

  (int diasEnMes, int weekdayPrimerDia) _infoMes() {
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes =
        DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    return (diasEnMes, primerDia.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    final (diasEnMes, weekdayPrimerDia) = _infoMes();
    final offsetInicio  = weekdayPrimerDia - 1;
    final totalCeldas   = offsetInicio + diasEnMes;
    final filas         = (totalCeldas / 7).ceil();
    final celdasTotales = filas * 7;

    return Scaffold(
      appBar: CabeceraWizard(
        pasoActual: 2,
        totalPasos: 5,
        titulo: 'Elige la fecha',
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Navegación de mes ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: 'Mes anterior',
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _mesAnterior,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _mesActual.year.toString(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    Text(
                      _nombresMes[_mesActual.month],
                      style: textTheme.displaySmall,
                    ),
                  ],
                ),
                Tooltip(
                  message: 'Mes siguiente',
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _mesSiguiente,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Cabeceras días de la semana ────────────────────────────────
            Row(
              children: _cabeceras.map((c) {
                return Expanded(
                  child: Center(
                    child: Text(
                      c,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // ── Grid de días ───────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: celdasTotales,
                itemBuilder: (context, index) {
                  if (index < offsetInicio ||
                      index >= offsetInicio + diasEnMes) {
                    return const SizedBox.shrink();
                  }
                  final dia          = index - offsetInicio + 1;
                  final bloqueado    = _esBloqueado(dia);
                  final esHoy        = _esHoy(dia);
                  final seleccionado = _esSeleccionado(dia);

                  final Color fondo;
                  final Color textoColor;
                  BoxBorder? borde;

                  if (seleccionado) {
                    fondo      = colorScheme.primary;
                    textoColor = colorScheme.onPrimary;
                  } else if (bloqueado) {
                    fondo      = Colors.transparent;
                    textoColor = colorScheme.outline.withOpacity(0.4);
                  } else {
                    fondo      = Colors.transparent;
                    textoColor = colorScheme.onSurface;
                    if (esHoy) {
                      borde = Border.all(
                        color: colorScheme.primary,
                        width: 1.5,
                      );
                    }
                  }

                  return GestureDetector(
                    onTap: bloqueado
                        ? null
                        : () => setState(() {
                              _diaSeleccionado = DateTime(
                                _mesActual.year,
                                _mesActual.month,
                                dia,
                              );
                            }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fondo,
                        borderRadius: BorderRadius.circular(8),
                        border: borde,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dia',
                        style: textTheme.bodyLarge?.copyWith(
                          color: textoColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Nota informativa ───────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                  Icon(Icons.info_outline,
                      size: 16, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    'Selecciona un día disponible',
                    style: textTheme.bodySmall,
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
            onPressed: _diaSeleccionado != null
                ? () => GestorNavegacion.irAWizardHora(context)
                : null,
            child: const Text('Siguiente'),
          ),
        ),
      ),
    );
  }
}