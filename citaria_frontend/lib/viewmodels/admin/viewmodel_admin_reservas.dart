import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum FiltroAdminReservas { hoy, semana, pendientes, confirmadas, canceladas }

@immutable
class DtoReservaAdmin {
  const DtoReservaAdmin({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.fechaHoraTexto,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String cliente;
  final String servicio;
  final String empleado;
  final String fechaHoraTexto;
  final String precio;
  final EstadoReserva estado;
}

@immutable
class DtoLineaDetalleReservaAdmin {
  const DtoLineaDetalleReservaAdmin({
    required this.servicio,
    required this.empleado,
    required this.horarioTexto,
    required this.duracionTexto,
    required this.precioTexto,
    required this.estadoTexto,
  });

  final String servicio;
  final String empleado;
  final String horarioTexto;
  final String duracionTexto;
  final String precioTexto;
  final String? estadoTexto;
}

@immutable
class DtoDetalleReservaAdmin {
  const DtoDetalleReservaAdmin({
    required this.id,
    required this.estado,
    required this.cliente,
    required this.clienteId,
    required this.telefono,
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.fecha,
    required this.hora,
    required this.total,
    required this.observaciones,
    required this.motivo,
    required this.puedeConfirmar,
    required this.puedeCancelar,
    required this.puedeCambiarEstado,
    required this.lineas,
  });

  final String id;
  final EstadoReserva estado;
  final String cliente;
  final String? clienteId;
  final String? telefono;
  final String servicio;
  final String duracion;
  final String empleado;
  final String fecha;
  final String hora;
  final String total;
  final String? observaciones;
  final String? motivo;
  final bool puedeConfirmar;
  final bool puedeCancelar;
  final bool puedeCambiarEstado;
  final List<DtoLineaDetalleReservaAdmin> lineas;
}

class ViewModelAdminReservas extends ViewModelAdminBase {
  ViewModelAdminReservas({
    required RepoReservas repoReservas,
    required RepoClientes repoClientes,
    required super.autenticacion,
    FiltroAdminReservas filtroInicial = FiltroAdminReservas.hoy,
  }) : _repoReservas = repoReservas,
       _repoClientes = repoClientes,
       _filtroActivo = filtroInicial;

  final RepoReservas _repoReservas;
  final RepoClientes _repoClientes;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );
  final DateFormat _formatoFecha = DateFormat('dd/MM', 'es_ES');
  final DateFormat _formatoFechaCompleta = DateFormat(
    'EEE d MMM yyyy',
    'es_ES',
  );

  List<Reserva> _reservas = const <Reserva>[];
  Map<int, List<ReservaServicio>> _detallesPorReserva =
      const <int, List<ReservaServicio>>{};
  FiltroAdminReservas _filtroActivo;
  DtoDetalleReservaAdmin? _detalle;

  FiltroAdminReservas get filtroActivo => _filtroActivo;
  DtoDetalleReservaAdmin? get detalle => _detalle;

  List<DtoReservaAdmin> get reservas {
    return _reservas
        .where(_coincideConFiltro)
        .map(_crearDto)
        .toList(growable: false);
  }

  Future<void> cargarReservas() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Reserva> reservas = await _repoReservas.listarTodas(token);
      _reservas = reservas
          .where((reserva) => reserva.id != null)
          .toList(growable: false)
        ..sort(_compararReservas);
      _detallesPorReserva = await _cargarDetallesReservas(token, _reservas);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarReservas();
  }

  Future<void> cargarDetalleReserva(int id) async {
    _detalle = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Reserva reserva = await _repoReservas.obtenerPorId(id, token);
      final List<ReservaServicio> detalles = await _repoReservas
          .obtenerDetalles(id, token);
      final Cliente? cliente = await _obtenerClienteSiEsPosible(
        reserva,
        token,
      );
      _detalle = _crearDetalle(reserva, detalles, cliente);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> cambiarEstadoReserva(int id, EstadoReserva estado) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoReservas.actualizarEstado(id, estado, token);
      await _recargarTrasAccion(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> confirmarReserva(int id) {
    return cambiarEstadoReserva(id, EstadoReserva.confirmada);
  }

  Future<bool> cancelarReserva(int id, {String? motivo}) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoReservas.cancelar(id, token, motivo: motivo);
      await _recargarTrasAccion(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  void seleccionarFiltro(FiltroAdminReservas filtro) {
    if (_filtroActivo == filtro) {
      return;
    }
    _filtroActivo = filtro;
    notifyListeners();
  }

  bool _coincideConFiltro(Reserva reserva) {
    return switch (_filtroActivo) {
      FiltroAdminReservas.hoy => _esMismoDia(reserva.fecha, DateTime.now()),
      FiltroAdminReservas.semana => _estaEnSemanaActual(reserva.fecha),
      FiltroAdminReservas.pendientes =>
        reserva.estado == EstadoReserva.pendiente,
      FiltroAdminReservas.confirmadas =>
        reserva.estado == EstadoReserva.confirmada,
      FiltroAdminReservas.canceladas =>
        reserva.estado == EstadoReserva.cancelada,
    };
  }

  DtoReservaAdmin _crearDto(Reserva reserva) {
    final List<ReservaServicio> detalles =
        _detallesPorReserva[reserva.id] ?? const <ReservaServicio>[];
    final ReservaServicio? primerDetalle = detalles.isEmpty
        ? null
        : detalles.first;
    return DtoReservaAdmin(
      id: reserva.id.toString(),
      cliente: _textoConFallback(reserva.nombreCliente, 'Cliente sin nombre'),
      servicio: detalles.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : detalles
                .map((detalle) => detalle.nombreServicio ?? 'Servicio')
                .join(', '),
      empleado: _textoConFallback(
        primerDetalle?.nombreEmpleado,
        'Sin empleado asignado',
      ),
      fechaHoraTexto: '${_formatoFecha.format(reserva.fecha)} · '
          '${_textoConFallback(reserva.horaInicio, '--:--')}',
      precio: _formatoPrecio.format(_calcularTotal(detalles)),
      estado: reserva.estado ?? EstadoReserva.pendiente,
    );
  }

  DtoDetalleReservaAdmin _crearDetalle(
    Reserva reserva,
    List<ReservaServicio> detalles,
    Cliente? cliente,
  ) {
    final ReservaServicio? primerDetalle = detalles.isEmpty
        ? null
        : detalles.first;
    final String empleado =
        primerDetalle?.nombreEmpleado ?? 'Sin empleado asignado';
    final int duracion = detalles.fold<int>(
      0,
      (suma, detalle) => suma + _duracionDetalle(detalle),
    );

    return DtoDetalleReservaAdmin(
      id: reserva.id.toString(),
      estado: reserva.estado ?? EstadoReserva.pendiente,
      cliente: _nombreCliente(reserva, cliente),
      clienteId: reserva.clienteId?.toString(),
      telefono: _textoOpcional(cliente?.telefono),
      servicio: detalles.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : detalles
                .map((detalle) => detalle.nombreServicio ?? 'Servicio')
                .join(', '),
      duracion: '$duracion min',
      empleado: empleado,
      fecha: _capitalizar(_formatoFechaCompleta.format(reserva.fecha)),
      hora: _textoConFallback(reserva.horaInicio, '--:--'),
      total: _formatoPrecio.format(_calcularTotal(detalles)),
      observaciones: _textoOpcional(reserva.notas),
      motivo: _textoOpcional(reserva.motivo),
      puedeConfirmar: reserva.estado == EstadoReserva.pendiente,
      puedeCancelar:
          reserva.estado == EstadoReserva.pendiente ||
          reserva.estado == EstadoReserva.confirmada,
      puedeCambiarEstado: reserva.estado != EstadoReserva.cancelada,
      lineas: detalles.map(_crearLineaDetalle).toList(growable: false),
    );
  }

  DtoLineaDetalleReservaAdmin _crearLineaDetalle(ReservaServicio detalle) {
    final int duracion = _duracionDetalle(detalle);
    return DtoLineaDetalleReservaAdmin(
      servicio: _textoConFallback(detalle.nombreServicio, 'Servicio'),
      empleado: _textoConFallback(
        detalle.nombreEmpleado,
        'Sin empleado asignado',
      ),
      horarioTexto:
          '${_formatearHora(detalle.horaInicio)} - '
          '${_formatearHora(detalle.horaFin)}',
      duracionTexto: '$duracion min',
      precioTexto: _formatoPrecio.format(
        detalle.precioUnitario * (detalle.cantidad ?? 1),
      ),
      estadoTexto: _estadoDetalleTexto(detalle),
    );
  }

  int _compararReservas(Reserva a, Reserva b) {
    final int fecha = a.fecha.compareTo(b.fecha);
    if (fecha != 0) {
      return fecha;
    }
    return a.horaInicio.compareTo(b.horaInicio);
  }

  bool _esMismoDia(DateTime fecha, DateTime referencia) {
    return fecha.year == referencia.year &&
        fecha.month == referencia.month &&
        fecha.day == referencia.day;
  }

  bool _estaEnSemanaActual(DateTime fecha) {
    final DateTime hoy = DateTime.now();
    final DateTime inicioSemana = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    ).subtract(Duration(days: hoy.weekday - 1));
    final DateTime finSemana = inicioSemana.add(const Duration(days: 7));
    return !fecha.isBefore(inicioSemana) && fecha.isBefore(finSemana);
  }

  Future<void> _recargarTrasAccion(int id) async {
    final String token = leerTokenObligatorio();
    final Reserva reserva = await _repoReservas.obtenerPorId(id, token);
    final List<ReservaServicio> detalles = await _repoReservas.obtenerDetalles(
      id,
      token,
    );
    final Cliente? cliente = await _obtenerClienteSiEsPosible(reserva, token);
    _detalle = _crearDetalle(reserva, detalles, cliente);
    final List<Reserva> reservas = await _repoReservas.listarTodas(token);
    _reservas = reservas
        .where((reserva) => reserva.id != null)
        .toList(growable: false)
      ..sort(_compararReservas);
    _detallesPorReserva = await _cargarDetallesReservas(token, _reservas);
    notifyListeners();
  }

  Future<Map<int, List<ReservaServicio>>> _cargarDetallesReservas(
    String token,
    List<Reserva> reservas,
  ) async {
    final Map<int, List<ReservaServicio>> detalles =
        <int, List<ReservaServicio>>{};
    for (final Reserva reserva in reservas) {
      final int? id = reserva.id;
      if (id == null) {
        continue;
      }
      detalles[id] = await _repoReservas.obtenerDetalles(id, token);
    }
    return detalles;
  }

  double _calcularTotal(List<ReservaServicio> detalles) {
    return detalles.fold<double>(
      0,
      (suma, detalle) =>
          suma + detalle.precioUnitario * (detalle.cantidad ?? 1),
    );
  }

  int _duracionDetalle(ReservaServicio detalle) {
    final DateTime inicio = _parsearHora(detalle.horaInicio);
    final DateTime fin = _parsearHora(detalle.horaFin);
    return fin.difference(inicio).inMinutes;
  }

  DateTime _parsearHora(String hora) {
    final List<String> partes = hora.split(':');
    return DateTime(
      0,
      1,
      1,
      int.tryParse(partes.first) ?? 0,
      partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
    );
  }

  String _formatearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) {
      return hora;
    }
    return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
  }

  String _resumenServicios(int total) {
    return total == 1 ? '1 servicio' : '$total servicios';
  }

  String? _estadoDetalleTexto(ReservaServicio detalle) {
    final estado = detalle.estado;
    if (estado == null) {
      return null;
    }
    return switch (estado.name) {
      'activo' => 'Activo',
      'cancelado' => 'Cancelado',
      _ => estado.name,
    };
  }

  Future<Cliente?> _obtenerClienteSiEsPosible(
    Reserva reserva,
    String token,
  ) async {
    final int? clienteId = reserva.clienteId;
    if (clienteId == null) {
      return null;
    }
    try {
      return await _repoClientes.obtenerPorId(clienteId, token);
    } catch (_) {
      return null;
    }
  }

  String _nombreCliente(Reserva reserva, Cliente? cliente) {
    final String? nombreCompleto = cliente == null
        ? null
        : _unirNombre(cliente.nombre, cliente.apellidos);
    return _textoConFallback(
      nombreCompleto ?? reserva.nombreCliente,
      'Cliente sin nombre',
    );
  }

  String _unirNombre(String nombre, String? apellidos) {
    final String? apellidosLimpios = _textoOpcional(apellidos);
    if (apellidosLimpios == null) {
      return nombre;
    }
    return '$nombre $apellidosLimpios';
  }

  String _textoConFallback(String? texto, String fallback) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) {
      return texto;
    }
    return '${texto.substring(0, 1).toUpperCase()}${texto.substring(1)}';
  }
}
