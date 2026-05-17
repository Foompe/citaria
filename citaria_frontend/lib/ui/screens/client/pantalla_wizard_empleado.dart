import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';

class PantallaWizardEmpleado extends StatelessWidget {
  const PantallaWizardEmpleado({super.key});

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wizard = context.watch<ViewModelWizard>();
    final empleado = wizard.empleadoAutomatico;

    return Scaffold(
      appBar: const CabeceraWizard(
        pasoActual: 1,
        totalPasos: 5,
        titulo: 'Elige tu profesional',
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 16),
        children: [
          GestureDetector(
            onTap: () =>
                context.read<ViewModelWizard>().seleccionarEmpleadoAutomatico(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                border: Border.all(color: colorScheme.primary),
                borderRadius: espaciado.radioCard,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: espaciado.radioBoton,
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          empleado.nombre,
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(empleado.rol, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  _RadioVisual(seleccionado: empleado.seleccionado),
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
            onPressed: () => GestorNavegacion.irAWizardFecha(
              context,
              context.read<ViewModelWizard>(),
            ),
            child: const Text('Siguiente'),
          ),
        ),
      ),
    );
  }
}

class _RadioVisual extends StatelessWidget {
  const _RadioVisual({required this.seleccionado});

  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: seleccionado ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        color: seleccionado ? colorScheme.primary : Colors.transparent,
      ),
      child: seleccionado
          ? Icon(Icons.circle, size: 8, color: colorScheme.onPrimary)
          : null,
    );
  }
}
