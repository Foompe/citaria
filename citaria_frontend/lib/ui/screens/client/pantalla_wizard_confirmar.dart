import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';

class PantallaWizardConfirmar extends StatefulWidget {
  const PantallaWizardConfirmar({super.key});

  @override
  State<PantallaWizardConfirmar> createState() =>
      _PantallaWizardConfirmarState();
}

class _PantallaWizardConfirmarState extends State<PantallaWizardConfirmar> {
  final TextEditingController _ctrlObservaciones = TextEditingController();

  @override
  void dispose() {
    _ctrlObservaciones.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final ViewModelWizard wizard = context.read<ViewModelWizard>();
    final sesion = context.read<ViewModelAutenticacion>().obtenerSesion();
    final bool ok = await wizard.confirmarReserva(sesion);
    if (!mounted || !ok) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reserva confirmada'),
        content: const Text(
          'Tu reserva está pendiente de confirmación por el establecimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    GestorNavegacion.confirmarWizard(context, wizard.origen);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wizard = context.watch<ViewModelWizard>();
    final resumen = wizard.resumen;

    return Scaffold(
      appBar: const CabeceraWizard(
        pasoActual: 4,
        totalPasos: 5,
        titulo: 'Confirma tu reserva',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _FilaResumen(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: espaciado.radioBoton,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      etiqueta: 'Servicio',
                      valor: resumen.serviciosTexto,
                    ),
                    const Divider(height: 24),
                    _FilaResumen(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          resumen.profesionalIniciales,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      etiqueta: 'Profesional',
                      valor: resumen.profesionalTexto,
                    ),
                    const Divider(height: 24),
                    _FilaResumen(
                      leading: Icon(
                        Icons.calendar_month,
                        color: colorScheme.outline,
                      ),
                      etiqueta: 'Fecha y hora',
                      valor: resumen.fechaHoraTexto,
                      estiloValor: textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: textTheme.bodyLarge),
                        Text(
                          resumen.precioTotalTexto,
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Observaciones (opcional)', style: textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrlObservaciones,
              maxLines: 4,
              onChanged: (valor) => context
                  .read<ViewModelWizard>()
                  .actualizarObservaciones(valor),
              decoration: InputDecoration(
                hintText: 'Indica cualquier detalle que quieras que sepamos…',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              wizard.error ?? 'La reserva quedará pendiente de confirmación',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: wizard.error == null
                    ? colorScheme.outline
                    : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarraCtaFija(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    wizard.cargando ||
                        wizard.reservaCreada != null ||
                        !resumen.puedeConfirmar
                    ? null
                    : _confirmar,
                child: const Text('Confirmar reserva'),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    GestorNavegacion.cancelarWizard(context, wizard.origen),
                child: Text(
                  'Cancelar',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  const _FilaResumen({
    required this.leading,
    required this.etiqueta,
    required this.valor,
    this.estiloValor,
  });

  final Widget leading;
  final String etiqueta;
  final String valor;
  final TextStyle? estiloValor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(valor, style: estiloValor ?? textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
