import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/dto/dto_linea_detalle_reserva_cliente.dart';
import 'package:citaria_frontend/dto/dto_reserva_cliente.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as estado_ui;
import 'package:citaria_frontend/ui/widgets/detalle_widgets.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_reservas_cliente.dart';

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
    final bool ok = await context
        .read<ViewModelReservasCliente>()
        .cancelarReserva(id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      return;
    }
    final String mensaje =
        context.read<ViewModelReservasCliente>().error ??
        'No se ha podido cancelar la reserva.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reservas = context.watch<ViewModelReservasCliente>();
    final reserva = reservas.detalle;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Reserva'),
          ],
          body: reserva == null
              ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                child: Text(
                  reservas.cargando
                      ? 'Cargando reserva...'
                      : reservas.error ?? 'No se ha podido cargar la reserva.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX,
                espaciado.safeBottom + 24,
              ),
              children: [
                _CardResumen(
                  referencia: 'Reserva #${reserva.id}',
                  estado: _estadoUi(reserva.estado),
                ),
                const SizedBox(height: 12),
                _CardFecha(
                  fecha: reserva.fechaTexto,
                  hora: reserva.horaTexto,
                  duracion: reserva.duracionTexto,
                ),
                const SizedBox(height: 12),
                _CardServicios(
                  detalles: reserva.detalles,
                  servicioFallback: reserva.servicio,
                  profesionalFallback: reserva.profesionalNombre,
                ),
                const SizedBox(height: 12),
                _CardTotal(total: reserva.precioTotalTexto),
                if (reserva.notas != null &&
                    reserva.notas!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  CardTextoCitaria(
                    titulo: 'Observaciones',
                    icono: Icons.notes,
                    texto: reserva.notas!,
                  ),
                ],
                if (reserva.motivo != null &&
                    reserva.motivo!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  CardTextoCitaria(
                    titulo: 'Motivo de cancelación',
                    icono: Icons.info_outline,
                    texto: reserva.motivo!,
                  ),
                ],
              ],
            ),
        ),
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

class _CardResumen extends StatelessWidget {
  const _CardResumen({required this.referencia, required this.estado});

  final String referencia;
  final estado_ui.EstadoReserva estado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(referencia, style: textTheme.displaySmall)),
            const SizedBox(width: 12),
            estado_ui.ChipEstado(estado: estado),
          ],
        ),
      ),
    );
  }
}

class _CardFecha extends StatelessWidget {
  const _CardFecha({
    required this.fecha,
    required this.hora,
    required this.duracion,
  });

  final String fecha;
  final String hora;
  final String duracion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CardSeccionCitaria(
      titulo: 'Fecha y hora',
      child: Column(
        children: [
          FilaInfoCitaria(
            icono: Icons.calendar_today_outlined,
            label: 'Fecha',
            valor: fecha,
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          FilaInfoCitaria(icono: Icons.access_time, label: 'Hora', valor: hora),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          FilaInfoCitaria(icono: Icons.timelapse, label: 'Duración', valor: duracion),
        ],
      ),
    );
  }
}

class _CardServicios extends StatelessWidget {
  const _CardServicios({
    required this.detalles,
    required this.servicioFallback,
    required this.profesionalFallback,
  });

  final List<DtoLineaDetalleReservaCliente> detalles;
  final String servicioFallback;
  final String profesionalFallback;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CardSeccionCitaria(
      titulo: 'Servicios',
      child: detalles.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicioFallback, style: textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(profesionalFallback, style: textTheme.bodySmall),
              ],
            )
          : Column(
              children: [
                for (int i = 0; i < detalles.length; i++) ...[
                  _FilaDetalleServicio(detalle: detalles[i]),
                  if (i < detalles.length - 1) const Divider(height: 24),
                ],
              ],
            ),
    );
  }
}

class _CardTotal extends StatelessWidget {
  const _CardTotal({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text('Total', style: textTheme.bodyLarge)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                total,
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaDetalleServicio extends StatelessWidget {
  const _FilaDetalleServicio({required this.detalle});

  final DtoLineaDetalleReservaCliente detalle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detalle.servicio,
                style: textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                detalle.precioTexto,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LineaIconoCitaria(icono: Icons.person_outline, texto: detalle.profesional),
        const SizedBox(height: 6),
        LineaIconoCitaria(
          icono: Icons.access_time,
          texto: '${detalle.horaTexto} · ${detalle.duracionTexto}',
        ),
        if (detalle.cantidadTexto != null || detalle.estadoTexto != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (detalle.cantidadTexto != null)
                EtiquetaDetalleCitaria(texto: detalle.cantidadTexto!),
              if (detalle.estadoTexto != null)
                EtiquetaDetalleCitaria(texto: detalle.estadoTexto!),
            ],
          ),
        ],
      ],
    );
  }
}

