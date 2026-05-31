import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/detalle_widgets.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_reservas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P21 — Detalle de una reserva en el área admin.
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
      repoEmpleados: context.read<RepoEmpleados>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
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
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    return null;
  }
}

// Contenido

class _ContenidoDetalleReserva extends StatelessWidget {
  const _ContenidoDetalleReserva({required this.reservaId});

  final int? reservaId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModelAdminReservas>();
    final detalle = vm.detalle;

    return Scaffold(
      bottomNavigationBar: detalle == null
          ? null
          : _BarraAcciones(
              reservaId: reservaId,
              detalle: detalle,
              vm: vm,
            ),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Reserva'),
          ],
          body: _Cuerpo(reservaId: reservaId, detalle: detalle, vm: vm),
        ),
      ),
    );
  }
}

// Cuerpo

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({
    required this.reservaId,
    required this.detalle,
    required this.vm,
  });

  final int? reservaId;
  final DtoDetalleReservaAdmin? detalle;
  final ViewModelAdminReservas vm;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (reservaId == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado la reserva.',
        accionTexto: 'Volver',
        onAccion: () => Navigator.maybePop(context),
      );
    }

    if (vm.cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vm.error;
    if (error != null && detalle == null) {
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vm.cargarDetalleReserva(reservaId!),
      );
    }

    final DtoDetalleReservaAdmin? datos = detalle;
    if (datos == null) {
      return EstadoCentrado(
        mensaje: 'No se ha podido cargar la reserva.',
        accionTexto: 'Reintentar',
        onAccion: () => vm.cargarDetalleReserva(reservaId!),
      );
    }

    final estadoMostrado = vm.estadoPendiente ?? datos.estado;

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 24),
      children: [
        _CardEstado(
          reservaId: datos.id,
          estadoMostrado: estadoMostrado,
          puedeCambiar: datos.puedeCambiarEstado && !vm.cargando,
          onCambiarEstado: (nuevo) => vm.seleccionarEstadoPendiente(nuevo),
        ),
        const SizedBox(height: 12),
        _CardCliente(
          nombre: datos.cliente,
          telefono: datos.telefono,
          clienteId: datos.clienteId,
          fotoUrlCliente: datos.fotoUrlCliente,
        ),
        const SizedBox(height: 12),
        _CardServicios(
          servicio: datos.servicio,
          empleado: datos.empleado,
          lineas: datos.lineas,
        ),
        const SizedBox(height: 12),
        _CardFechaTotal(fecha: datos.fecha, hora: datos.hora, total: datos.total),
        if (datos.observaciones != null) ...[
          const SizedBox(height: 12),
          CardTextoCitaria(
            titulo: 'Observaciones',
            icono: Icons.notes,
            texto: datos.observaciones!,
          ),
        ],
        if (datos.motivo != null) ...[
          const SizedBox(height: 12),
          CardTextoCitaria(
            titulo: 'Motivo de cancelación',
            icono: Icons.info_outline,
            texto: datos.motivo!,
          ),
        ],
        const SizedBox(height: 120),
      ],
    );
  }
}

// Barra de acciones

class _BarraAcciones extends StatelessWidget {
  const _BarraAcciones({
    required this.reservaId,
    required this.detalle,
    required this.vm,
  });

  final int? reservaId;
  final DtoDetalleReservaAdmin detalle;
  final ViewModelAdminReservas vm;

  @override
  Widget build(BuildContext context) {
    final int? id = reservaId;
    if (id == null) return const SizedBox.shrink();

    final bool hayCambio = vm.estadoPendiente != null;
    final bool cargando = vm.cargando;

    return BarraCtaFija(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: hayCambio
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No hay cambios que confirmar'),
                      ),
                    ),
              child: ElevatedButton(
                onPressed: hayCambio && !cargando
                    ? () => _confirmar(context, id)
                    : null,
                child: cargando
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Confirmar'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: cargando
                  ? null
                  : () {
                      vm.descartarEstadoPendiente();
                      Navigator.maybePop(context);
                    },
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar(BuildContext context, int id) async {
    final estado = vm.estadoPendiente;
    if (estado == null) return;
    final bool ok = await vm.cambiarEstadoReserva(id, estado);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo guardar.')),
      );
    }
  }
}

// Card estado

class _CardEstado extends StatelessWidget {
  const _CardEstado({
    required this.reservaId,
    required this.estadoMostrado,
    required this.puedeCambiar,
    required this.onCambiarEstado,
  });

  final String reservaId;
  final datos.EstadoReserva estadoMostrado;
  final bool puedeCambiar;
  final ValueChanged<datos.EstadoReserva> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text('Reserva #$reservaId', style: textTheme.displaySmall),
            ),
            DropdownButton<datos.EstadoReserva>(
              value: estadoMostrado,
              underline: const SizedBox.shrink(),
              onChanged: puedeCambiar
                  ? (valor) {
                      if (valor != null) onCambiarEstado(valor);
                    }
                  : null,
              items: _estadosPermitidos(estadoMostrado).map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: chip.ChipEstado(estado: _estadoVisual(e)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Card cliente

class _CardCliente extends StatelessWidget {
  const _CardCliente({
    required this.nombre,
    required this.telefono,
    required this.clienteId,
    required this.fotoUrlCliente,
  });

  final String nombre;
  final String? telefono;
  final String? clienteId;
  final String? fotoUrlCliente;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return CardSeccionCitaria(
      titulo: 'Cliente',
      child: Row(
        children: [
          AvatarFallbackCitaria(
            texto: nombre,
            imagenUrl: fotoUrlCliente,
            tamano: 40,
            radio: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: textTheme.displaySmall),
                if (telefono != null)
                  Text(
                    telefono!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
              ],
            ),
          ),
          if (clienteId != null)
            SizedBox(
              width: 90,
              child: OutlinedButton(
                onPressed: () =>
                    GestorNavegacion.irAAdminDetalleCliente(context, clienteId!),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Ver ficha'),
              ),
            ),
        ],
      ),
    );
  }
}

// Card servicios

class _CardServicios extends StatelessWidget {
  const _CardServicios({
    required this.servicio,
    required this.empleado,
    required this.lineas,
  });

  final String servicio;
  final String empleado;
  final List<DtoLineaDetalleReservaAdmin> lineas;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CardSeccionCitaria(
      titulo: 'Servicios',
      child: lineas.isNotEmpty
          ? Column(
              children: [
                for (int i = 0; i < lineas.length; i++) ...[
                  _FilaLinea(linea: lineas[i]),
                  if (i < lineas.length - 1) const Divider(height: 24),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio, style: textTheme.bodyLarge),
                const SizedBox(height: 4),
                LineaIconoCitaria(
                  icono: Icons.person_outline,
                  texto: empleado,
                ),
              ],
            ),
    );
  }
}

class _FilaLinea extends StatelessWidget {
  const _FilaLinea({required this.linea});

  final DtoLineaDetalleReservaAdmin linea;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(linea.servicio, style: textTheme.bodyLarge),
            ),
            Text(
              linea.precioTexto,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LineaIconoCitaria(
          icono: Icons.person_outline,
          texto: linea.empleado,
        ),
        const SizedBox(height: 4),
        LineaIconoCitaria(
          icono: Icons.access_time,
          texto: '${linea.horarioTexto} · ${linea.duracionTexto}',
        ),
        if (linea.estadoTexto != null) ...[
          const SizedBox(height: 6),
          EtiquetaDetalleCitaria(texto: linea.estadoTexto!),
        ],
      ],
    );
  }
}

// Card fecha + total

class _CardFechaTotal extends StatelessWidget {
  const _CardFechaTotal({
    required this.fecha,
    required this.hora,
    required this.total,
  });

  final String fecha;
  final String hora;
  final String total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilaInfoCitaria(
              icono: Icons.calendar_today_outlined,
              label: 'Fecha y hora',
              valor: '$fecha  ·  $hora',
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

// Helper

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

List<datos.EstadoReserva> _estadosPermitidos(datos.EstadoReserva actual) {
  return switch (actual) {
    datos.EstadoReserva.pendiente => [
        datos.EstadoReserva.pendiente,
        datos.EstadoReserva.confirmada,
        datos.EstadoReserva.cancelada,
      ],
    datos.EstadoReserva.confirmada => [
        datos.EstadoReserva.confirmada,
        datos.EstadoReserva.pendiente,
        datos.EstadoReserva.cancelada,
      ],
    _ => [actual],
  };
}
