import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_reservas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P21 — Detalle de una reserva en el área admin.
///
/// Ruta: /admin/reservas/:id  — arguments: {'id': String}
class PantallaAdminDetalleReserva extends StatefulWidget {
  const PantallaAdminDetalleReserva({super.key});

  @override
  State<PantallaAdminDetalleReserva> createState() =>
      _PantallaAdminDetalleReservaState();
}

class _PantallaAdminDetalleReservaState
    extends State<PantallaAdminDetalleReserva> {
  late final ViewModelAdminReservas _viewModel;
  int? _reservaId;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminReservas(
      repoReservas: context.read<RepoReservas>(),
      repoClientes: context.read<RepoClientes>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;

    final int? id = _leerIdReserva(context);
    _reservaId = id;
    if (id != null) {
      _viewModel.cargarDetalleReserva(id);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminReservas>.value(
      value: _viewModel,
      child: _ContenidoDetalleReserva(reservaId: _reservaId),
    );
  }

  int? _leerIdReserva(BuildContext context) {
    final Object? argumentos = ModalRoute.of(context)?.settings.arguments;
    if (argumentos is Map<String, dynamic>) {
      final Object? id = argumentos['id'];
      if (id is int) {
        return id;
      }
      if (id is String) {
        return int.tryParse(id);
      }
    }
    return null;
  }
}

class _ContenidoDetalleReserva extends StatelessWidget {
  const _ContenidoDetalleReserva({required this.reservaId});

  final int? reservaId;

  @override
  Widget build(BuildContext context) {
    final vmReservas = context.watch<ViewModelAdminReservas>();
    final detalle = vmReservas.detalle;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Reserva',
        mostrarAtras: true,
        accionDerecha: detalle == null
            ? null
            : Tooltip(
                message: 'Actualizar',
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: reservaId == null
                      ? null
                      : () => vmReservas.cargarDetalleReserva(reservaId!),
                ),
              ),
      ),
      bottomNavigationBar: detalle == null
          ? null
          : _BarraAccionesDetalle(
              reservaId: reservaId,
              detalle: detalle,
              vmReservas: vmReservas,
            ),
      body: _CuerpoDetalleReserva(
        reservaId: reservaId,
        detalle: detalle,
        vmReservas: vmReservas,
        espaciado: espaciado,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}

class _CuerpoDetalleReserva extends StatelessWidget {
  const _CuerpoDetalleReserva({
    required this.reservaId,
    required this.detalle,
    required this.vmReservas,
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final int? reservaId;
  final DtoDetalleReservaAdmin? detalle;
  final ViewModelAdminReservas vmReservas;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (reservaId == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado la reserva.',
        accionTexto: 'Volver',
        onAccion: () => Navigator.maybePop(context),
      );
    }

    if (vmReservas.cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmReservas.error;
    if (error != null && detalle == null) {
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vmReservas.cargarDetalleReserva(reservaId!),
      );
    }

    final DtoDetalleReservaAdmin? datos = detalle;
    if (datos == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado la reserva.',
        accionTexto: 'Reintentar',
        onAccion: () => vmReservas.cargarDetalleReserva(reservaId!),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 24),
      children: [
        _CardEstado(
          estado: datos.estado,
          puedeCambiarEstado: datos.puedeCambiarEstado,
          cargando: vmReservas.cargando,
          espaciado: espaciado,
          onCambiarEstado: (nuevo) =>
              vmReservas.cambiarEstadoReserva(reservaId!, nuevo),
        ),
        const SizedBox(height: 12),
        _CardCliente(
          nombre: datos.cliente,
          telefono: datos.telefono,
          clienteId: datos.clienteId,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        _CardServicioEmpleado(
          servicio: datos.servicio,
          duracion: datos.duracion,
          empleado: datos.empleado,
          lineas: datos.lineas,
          colorScheme: colorScheme,
          textTheme: textTheme,
          espaciado: espaciado,
        ),
        const SizedBox(height: 12),
        _CardFechaTotal(
          fecha: datos.fecha,
          hora: datos.hora,
          total: datos.total,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        if (datos.observaciones != null) ...[
          const SizedBox(height: 12),
          _CardTexto(
            titulo: 'OBSERVACIONES',
            texto: datos.observaciones!,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
        if (datos.motivo != null) ...[
          const SizedBox(height: 12),
          _CardTexto(
            titulo: 'MOTIVO',
            texto: datos.motivo!,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
        const SizedBox(height: 120),
      ],
    );
  }
}

class _BarraAccionesDetalle extends StatelessWidget {
  const _BarraAccionesDetalle({
    required this.reservaId,
    required this.detalle,
    required this.vmReservas,
  });

  final int? reservaId;
  final DtoDetalleReservaAdmin detalle;
  final ViewModelAdminReservas vmReservas;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final int? id = reservaId;
    if (id == null || (!detalle.puedeConfirmar && !detalle.puedeCancelar)) {
      return const SizedBox.shrink();
    }

    return BarraCtaFija(
      child: Row(
        children: [
          if (detalle.puedeConfirmar) ...[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: vmReservas.cargando
                    ? null
                    : () => _ejecutarAccion(
                        context,
                        vmReservas.confirmarReserva(id),
                        'Reserva confirmada',
                        vmReservas,
                      ),
                child: const Text('Confirmar'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (detalle.puedeCancelar)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                ),
                onPressed: vmReservas.cargando
                    ? null
                    : () => _ejecutarAccion(
                        context,
                        vmReservas.cancelarReserva(id),
                        'Reserva cancelada',
                        vmReservas,
                      ),
                child: const Text('Cancelar'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _ejecutarAccion(
    BuildContext context,
    Future<bool> accion,
    String mensajeOk,
    ViewModelAdminReservas vmReservas,
  ) async {
    final bool ok = await accion;
    if (!context.mounted) {
      return;
    }
    final String? error = vmReservas.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? mensajeOk : error ?? 'No se pudo guardar.')),
    );
  }
}

class _CardEstado extends StatelessWidget {
  const _CardEstado({
    required this.estado,
    required this.puedeCambiarEstado,
    required this.cargando,
    required this.espaciado,
    required this.onCambiarEstado,
  });

  final datos.EstadoReserva estado;
  final bool puedeCambiarEstado;
  final bool cargando;
  final EspaciadoCitaria espaciado;
  final ValueChanged<datos.EstadoReserva> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            chip.ChipEstado(estado: _estadoVisual(estado)),
            const Spacer(),
            DropdownButton<datos.EstadoReserva>(
              value: estado,
              underline: const SizedBox.shrink(),
              onChanged: puedeCambiarEstado && !cargando
                  ? (valor) {
                      if (valor != null && valor != estado) {
                        onCambiarEstado(valor);
                      }
                    }
                  : null,
              items: datos.EstadoReserva.values.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: chip.ChipEstado(estado: _estadoVisual(estado)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCliente extends StatelessWidget {
  const _CardCliente({
    required this.nombre,
    required this.telefono,
    required this.clienteId,
    required this.colorScheme,
    required this.textTheme,
  });

  final String nombre;
  final String? telefono;
  final String? clienteId;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLIENTE',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AvatarFallbackCitaria(texto: nombre, tamano: 40, radio: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: textTheme.displaySmall),
                      if (telefono != null)
                        Text(
                          telefono!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                if (clienteId != null)
                  SizedBox(
                    width: 90,
                    child: OutlinedButton(
                      onPressed: () => GestorNavegacion.irAAdminDetalleCliente(
                        context,
                        clienteId!,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Ver ficha'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardServicioEmpleado extends StatelessWidget {
  const _CardServicioEmpleado({
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.lineas,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final String servicio;
  final String duracion;
  final String empleado;
  final List<DtoLineaDetalleReservaAdmin> lineas;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SERVICIO + EMPLEADO',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(servicio, style: textTheme.bodyLarge)),
                Text(
                  duracion,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                AvatarFallbackCitaria(texto: empleado, tamano: 32, radio: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(empleado, style: textTheme.bodyLarge)),
              ],
            ),
            if (lineas.isNotEmpty) ...[
              const Divider(height: 24),
              ...lineas.map(
                (linea) => _FilaLineaDetalle(
                  linea: linea,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilaLineaDetalle extends StatelessWidget {
  const _FilaLineaDetalle({
    required this.linea,
    required this.colorScheme,
    required this.textTheme,
  });

  final DtoLineaDetalleReservaAdmin linea;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(linea.servicio, style: textTheme.bodyMedium)),
              Text(
                linea.precioTexto,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${linea.empleado} · ${linea.horarioTexto} · '
            '${linea.duracionTexto}',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          if (linea.estadoTexto != null) ...[
            const SizedBox(height: 4),
            Text(
              linea.estadoTexto!,
              style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardFechaTotal extends StatelessWidget {
  const _CardFechaTotal({
    required this.fecha,
    required this.hora,
    required this.total,
    required this.colorScheme,
    required this.textTheme,
  });

  final String fecha;
  final String hora;
  final String total;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text('$fecha  ·  $hora', style: textTheme.bodyMedium),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: textTheme.bodyLarge),
                Text(
                  total,
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTexto extends StatelessWidget {
  const _CardTexto({
    required this.titulo,
    required this.texto,
    required this.colorScheme,
    required this.textTheme,
  });

  final String titulo;
  final String texto;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(texto, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}


chip.EstadoReserva _estadoVisual(datos.EstadoReserva estado) {
  switch (estado) {
    case datos.EstadoReserva.pendiente:
      return chip.EstadoReserva.pendiente;
    case datos.EstadoReserva.confirmada:
      return chip.EstadoReserva.confirmada;
    case datos.EstadoReserva.cancelada:
      return chip.EstadoReserva.cancelada;
    case datos.EstadoReserva.completada:
      return chip.EstadoReserva.completada;
  }
}
