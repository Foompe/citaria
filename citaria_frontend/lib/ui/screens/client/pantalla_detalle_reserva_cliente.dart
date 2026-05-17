import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as estado_ui;
import 'package:citaria_frontend/viewmodels/viewmodel_reservas_cliente.dart';

class PantallaDetalleReservaCliente extends StatefulWidget {
  const PantallaDetalleReservaCliente({super.key});

  @override
  State<PantallaDetalleReservaCliente> createState() =>
      _PantallaDetalleReservaClienteState();
}

class _PantallaDetalleReservaClienteState
    extends State<PantallaDetalleReservaCliente> {
  bool _iniciado = false;
  int? _id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, Object?>) {
      final Object? idArg = args['id'];
      _id = int.tryParse(idArg?.toString() ?? '');
    }
    final int? id = _id;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ViewModelReservasCliente>().cargarDetalleReserva(id);
      });
    }
  }

  Future<void> _cancelar() async {
    final int? id = _id;
    if (id == null) return;
    await context.read<ViewModelReservasCliente>().cancelarReserva(id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final reservas = context.watch<ViewModelReservasCliente>();
    final reserva = reservas.detalle;

    return Scaffold(
      body: reserva == null
          ? Center(
              child: Text(
                reservas.cargando
                    ? 'Cargando reserva...'
                    : 'No se ha podido cargar la reserva.',
                style: textTheme.bodyLarge,
              ),
            )
          : Stack(
              children: [
                Container(
                  height: screenHeight * 0.32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: espaciado.safeTop,
                  left: espaciado.padX,
                  child: Semantics(
                    label: 'Volver',
                    child: Tooltip(
                      message: 'Volver',
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: espaciado.radioPill,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.30),
                            borderRadius: espaciado.radioPill,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.32 - 22,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(espaciado.radioCard.topLeft.x * 2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        espaciado.padX,
                        16,
                        espaciado.padX,
                        espaciado.safeBottom + 80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: espaciado.radioPill,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          estado_ui.ChipEstado(
                            estado: _estadoUi(reserva.estado),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            reserva.servicio,
                            style: textTheme.displayMedium,
                          ),
                          const SizedBox(height: 20),
                          _CardSeccion(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text(
                                    reserva.profesionalIniciales,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reserva.profesionalNombre,
                                      style: textTheme.displaySmall,
                                    ),
                                    Text(
                                      reserva.profesionalRol,
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CardSeccion(
                            child: Column(
                              children: [
                                _FilaInfo(
                                  icono: Icons.calendar_today,
                                  label: 'Fecha',
                                  valor: reserva.fechaTexto,
                                ),
                                Divider(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  height: 20,
                                ),
                                _FilaInfo(
                                  icono: Icons.access_time,
                                  label: 'Hora / Duración',
                                  valor:
                                      '${reserva.horaTexto} · ${reserva.duracionTexto}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CardSeccion(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: textTheme.bodyLarge),
                                Text(
                                  reserva.precioTotalTexto,
                                  style: textTheme.displaySmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (reserva.notas != null) ...[
                            const SizedBox(height: 10),
                            _CardSeccion(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.notes,
                                    size: 18,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      reserva.notas ?? '',
                                      style: textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: reserva == null || !reserva.puedeCancelar
          ? null
          : BarraCtaFija(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: reservas.cargando ? null : _cancelar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                  child: const Text('Cancelar reserva'),
                ),
              ),
            ),
    );
  }
}

estado_ui.EstadoReserva _estadoUi(EstadoReservaPresentacion estado) {
  return switch (estado) {
    EstadoReservaPresentacion.confirmada => estado_ui.EstadoReserva.confirmada,
    EstadoReservaPresentacion.cancelada => estado_ui.EstadoReserva.cancelada,
    EstadoReservaPresentacion.completada => estado_ui.EstadoReserva.completada,
    EstadoReservaPresentacion.pendiente => estado_ui.EstadoReserva.pendiente,
  };
}

class _CardSeccion extends StatelessWidget {
  const _CardSeccion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: espaciado.radioCard,
      ),
      child: child,
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.label,
    required this.valor,
  });

  final IconData icono;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.outline),
        const SizedBox(width: 10),
        Text(label, style: textTheme.bodySmall),
        const Spacer(),
        Text(valor, style: textTheme.bodyMedium),
      ],
    );
  }
}
