import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';

class PantallaWizardFecha extends StatefulWidget {
  const PantallaWizardFecha({super.key});

  @override
  State<PantallaWizardFecha> createState() => _PantallaWizardFechaState();
}

class _PantallaWizardFechaState extends State<PantallaWizardFecha> {
  bool _iniciado = false;

  static const List<String> _cabeceras = <String>[
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  static const List<String> _nombresMes = <String>[
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelWizard>().cargarDiasDisponibles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wizard = context.watch<ViewModelWizard>();
    final dias = wizard.diasCalendario;

    return Scaffold(
      appBar: const CabeceraWizard(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: 'Mes anterior',
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: wizard.puedeMesAnterior
                        ? () => context.read<ViewModelWizard>().cambiarMes(-1)
                        : null,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      wizard.mesVisible.year.toString(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    Text(
                      _nombresMes[wizard.mesVisible.month],
                      style: textTheme.displaySmall,
                    ),
                  ],
                ),
                Tooltip(
                  message: 'Mes siguiente',
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: wizard.puedeMesSiguiente
                        ? () => context.read<ViewModelWizard>().cambiarMes(1)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: _cabeceras.map((cabecera) {
                return Expanded(
                  child: Center(
                    child: Text(
                      cabecera,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                key: ValueKey(
                  '${wizard.mesVisible.year}-'
                  '${wizard.mesVisible.month}-'
                  '${wizard.versionDiasCalendario}',
                ),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: dias.length,
                itemBuilder: (context, index) {
                  final dia = dias[index];
                  if (!dia.esDelMes) return const SizedBox.shrink();

                  final Color fondo;
                  final Color textoColor;
                  BoxBorder? borde;

                  if (dia.seleccionado) {
                    fondo = colorScheme.primary;
                    textoColor = colorScheme.onPrimary;
                  } else if (dia.disponible) {
                    fondo = colorScheme.primaryContainer;
                    textoColor = colorScheme.onPrimaryContainer;
                    borde = Border.all(
                      color: dia.esHoy
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.35),
                      width: dia.esHoy ? 1.5 : 1,
                    );
                  } else {
                    fondo = Colors.transparent;
                    textoColor = colorScheme.outline.withValues(alpha: 0.4);
                    if (dia.esHoy) {
                      borde = Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                        width: 1.5,
                      );
                    }
                  }

                  return GestureDetector(
                    onTap: dia.disponible
                        ? () => context
                              .read<ViewModelWizard>()
                              .seleccionarFecha(dia.fecha)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fondo,
                        borderRadius: BorderRadius.circular(8),
                        border: borde,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${dia.dia}',
                        style: textTheme.bodyLarge?.copyWith(color: textoColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: espaciado.radioCard,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wizard.cargando
                          ? 'Cargando disponibilidad'
                          : wizard.error ?? 'Selecciona un día disponible',
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
            onPressed: wizard.fechaSeleccionada != null
                ? () => GestorNavegacion.irAWizardHora(
                    context,
                    context.read<ViewModelWizard>(),
                  )
                : null,
            child: const Text('Siguiente'),
          ),
        ),
      ),
    );
  }
}
