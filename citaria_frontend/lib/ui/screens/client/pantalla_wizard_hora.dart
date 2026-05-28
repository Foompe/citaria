import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';

class PantallaWizardHora extends StatelessWidget {
  const PantallaWizardHora({super.key});

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wizard = context.watch<ViewModelWizard>();
    final resumen = wizard.resumen;
    final franjas = wizard.franjas;

    return Scaffold(
      body: Column(
        children: [
          const CabeceraWizard(
            pasoActual: 3,
            totalPasos: 5,
            titulo: 'Elige la hora',
          ),
          Expanded(
            child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                    resumen.fechaHoraTexto,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '· ${resumen.duracionTotalTexto}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (franjas.isEmpty)
              Text(
                wizard.cargando
                    ? 'Cargando franjas...'
                    : 'No hay franjas disponibles para esta fecha.',
                style: textTheme.bodyLarge,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: franjas.map((franja) {
                  final Color fondo;
                  final Color textoColor;
                  BoxBorder? borde;

                  if (franja.seleccionada) {
                    fondo = colorScheme.primary;
                    textoColor = colorScheme.onPrimary;
                  } else if (!franja.disponible) {
                    fondo = colorScheme.outline.withValues(alpha: 0.1);
                    textoColor = colorScheme.outline.withValues(alpha: 0.4);
                  } else {
                    fondo = colorScheme.primaryContainer;
                    textoColor = colorScheme.onPrimaryContainer;
                    borde = Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                    );
                  }

                  return GestureDetector(
                    onTap: franja.disponible
                        ? () => context
                              .read<ViewModelWizard>()
                              .seleccionarFranja(franja.horaInicio)
                        : null,
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
                            franja.horaTexto,
                            style: textTheme.bodyMedium?.copyWith(
                              color: textoColor,
                            ),
                          ),
                          if (!franja.disponible) ...[
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          ),
        ],
      ),
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: resumen.puedeConfirmar
                ? () => GestorNavegacion.irAWizardConfirmar(
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
