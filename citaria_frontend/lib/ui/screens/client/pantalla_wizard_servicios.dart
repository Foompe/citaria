import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_wizard.dart';

class PantallaWizardServicios extends StatefulWidget {
  const PantallaWizardServicios({super.key, this.servicioPreseleccionado});

  final String? servicioPreseleccionado;

  @override
  State<PantallaWizardServicios> createState() =>
      _PantallaWizardServiciosState();
}

class _PantallaWizardServiciosState extends State<PantallaWizardServicios> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelWizard>().inicializar(
        servicioPreseleccionado: widget.servicioPreseleccionado,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wizard = context.watch<ViewModelWizard>();
    final servicios = wizard.servicios;
    final resumen = wizard.resumen;

    return Scaffold(
      body: Column(
        children: [
          const CabeceraWizard(
            pasoActual: 0,
            totalPasos: 5,
            titulo: 'Elige tus servicios',
          ),
          Expanded(
            child: servicios.isEmpty
          ? Center(
              child: Text(
                wizard.cargando
                    ? 'Cargando servicios...'
                    : 'No hay servicios disponibles.',
                style: textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.padX,
                vertical: 12,
              ),
              itemCount: servicios.length,
              separatorBuilder: (_, _) =>
                  Divider(color: colorScheme.outline.withValues(alpha: 0.15)),
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                return InkWell(
                  onTap: () => context.read<ViewModelWizard>().toggleServicio(
                    servicio.id,
                  ),
                  borderRadius: espaciado.radioCard,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: servicio.seleccionado
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: espaciado.radioBoton,
                            border: Border.all(
                              color: servicio.seleccionado
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: 1.5,
                            ),
                          ),
                          child: servicio.seleccionado
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                servicio.nombre,
                                style: textTheme.displaySmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    servicio.duracionTexto,
                                    style: textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    servicio.precioTexto,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        EtiquetaWizard(etiqueta: servicio.categoria),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraCtaFija(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(resumen.duracionTotalTexto, style: textTheme.bodySmall),
                  if (resumen.puedeContinuar)
                    Text(
                      resumen.precioTotalTexto,
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, maxWidth: 160),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.outline,
                ),
                onPressed: resumen.puedeContinuar
                    ? () => GestorNavegacion.irAWizardEmpleado(
                        context,
                        context.read<ViewModelWizard>(),
                      )
                    : null,
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
