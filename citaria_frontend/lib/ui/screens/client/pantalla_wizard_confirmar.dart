import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';

/// Paso 5 del wizard de reserva: confirmación.
///
/// Muestra el resumen de la reserva y permite añadir observaciones.
/// Al confirmar muestra el diálogo D02 y navega a inicio cliente.
///
/// Ruta: /nueva-reserva/confirmar
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

  Future<void> _mostrarDialogoConfirmado() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reserva confirmada'),
        content: const Text(
          'Tu reserva está pendiente de confirmación por el establecimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (confirmado == true && mounted) {
      GestorNavegacion.confirmarWizard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraWizard(
        pasoActual: 4,
        totalPasos: 5,
        titulo: 'Confirma tu reserva',
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX,
          16,
          espaciado.padX,
          espaciado.safeBottom + 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card resumen ───────────────────────────────────────────────
            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Servicio
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
                      // TODO: mostrar servicios reales del wizard state
                      valor: 'Lavado Premium + Encerado',
                    ),
                    const Divider(height: 24),

                    // Profesional
                    _FilaResumen(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          // TODO: mostrar profesional real del wizard state
                          'CM',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      etiqueta: 'Profesional',
                      // TODO: mostrar profesional real del wizard state
                      valor: 'Carlos M.',
                    ),
                    const Divider(height: 24),

                    // Fecha y hora
                    _FilaResumen(
                      leading: Icon(
                        Icons.calendar_month,
                        color: colorScheme.outline,
                      ),
                      etiqueta: 'Fecha y hora',
                      // TODO: mostrar fecha y hora reales del wizard state
                      valor: 'Mar 21 abr · 10:30',
                      estiloValor: textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: textTheme.bodyLarge),
                        // TODO: mostrar precio total real del wizard state
                        Text(
                          '110 €',
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

            // ── Observaciones ──────────────────────────────────────────────
            Text('Observaciones (opcional)', style: textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrlObservaciones,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Indica cualquier detalle que quieras que sepamos…',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),

            // Texto informativo — fuera de la barra para evitar overflow
            const SizedBox(height: 16),
            Text(
              'La reserva quedará pendiente de confirmación',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            // Espacio para que el texto no quede tapado por la barra
            const SizedBox(height: 140),
          ],
        ),
      ),

      // ── CTA fija — solo dos botones ───────────────────────────────────────
      bottomNavigationBar: BarraCtaFija(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _mostrarDialogoConfirmado,
                child: const Text('Confirmar reserva'),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => GestorNavegacion.cancelarWizard(context),
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

// ── Widget auxiliar fila del resumen ─────────────────────────────────────────

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(valor, style: estiloValor ?? textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}