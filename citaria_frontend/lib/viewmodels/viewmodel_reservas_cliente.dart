import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum EstadoReservaPresentacion { pendiente, confirmada, cancelada, completada }

@immutable
class DtoReservaCliente {
  const DtoReservaCliente({
    required this.id,
    required this.estado,
    required this.nombreServicio,
    required this.metaFechaHora,
    required this.precioTexto,
    required this.esProxima,
  });

  final int id;
  final EstadoReservaPresentacion estado;
  final String nombreServicio;
  final String metaFechaHora;
  final String precioTexto;
  final bool esProxima;
}

@immutable
class DtoLineaDetalleReservaCliente {
  const DtoLineaDetalleReservaCliente({
    required this.servicio,
    required this.profesional,
    required this.horaTexto,
    required this.duracionTexto,
    required this.precioTexto,
    required this.cantidadTexto,
    required this.estadoTexto,
  });

  final String servicio;
  final String profesional;
  final String horaTexto;
  final String duracionTexto;
  final String precioTexto;
  final String? cantidadTexto;
  final String? estadoTexto;
}

@immutable
class DtoDetalleReservaCliente {
  const DtoDetalleReservaCliente({
    required this.id,
    required this.estado,
    required this.servicio,
    required this.profesionalNombre,
    required this.profesionalRol,
    required this.profesionalIniciales,
    required this.fechaTexto,
    required this.horaTexto,
    required this.duracionTexto,
    required this.precioTotalTexto,
    required this.notas,
    required this.motivo,
    required this.puedeCancelar,
    required this.detalles,
  });

  final int id;
  final EstadoReservaPresentacion estado;
  final String servicio;
  final String profesionalNombre;
  final String profesionalRol;
  final String profesionalIniciales;
  final String fechaTexto;
  final String horaTexto;
  final String duracionTexto;
  final String precioTotalTexto;
  final String? notas;
  final String? motivo;
  final bool puedeCancelar;
  final List<DtoLineaDetalleReservaCliente> detalles;
}

class ViewModelReservasCliente extends ChangeNotifier {
  ViewModelReservasCliente({
    required RepoReservas repoReservas,
    required ViewModelAutenticacion autenticacion,
  }) : _repoReservas = repoReservas,
       _autenticacion = autenticacion;

  final RepoReservas _repoReservas;
  final ViewModelAutenticacion _autenticacion;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );
  final DateFormat _formatoFecha = DateFormat('EEE d MMM', 'es_ES');

  bool _cargando = false;
  String? _error;
  List<Reserva> _reservas = const <Reserva>[];
  Map<int, double> _totalesReservas = const <int, double>{};
  DtoDetalleReservaCliente? _detalle;

  bool get cargando => _cargando;
  String? get error => _error;
  DtoDetalleReservaCliente? get detalle => _detalle;

  List<DtoReservaCliente> get proximas {
    return _crearDtos()
        .where((reserva) => reserva.esProxima)
        .toList(growable: false);
  }

  List<DtoReservaCliente> get pasadas {
    return _crearDtos()
        .where((reserva) => !reserva.esProxima)
        .toList(growable: false);
  }

  DtoReservaCliente? get proximaReserva {
    final List<DtoReservaCliente> datos = proximas;
    return datos.isEmpty ? null : datos.first;
  }

  void limpiar() {
    _reservas = const <Reserva>[];
    _totalesReservas = const <int, double>{};
    _detalle = null;
    _cargando = false;
    _error = null;
    notifyListeners();
  }

  Future<void> cargarReservasCliente() async {
    _setCargando(true);
    _limpiarError();

    try {
      await _cargarReservasInterno();
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cargarDetalleReserva(int id) async {
    _detalle = null;
    _setCargando(true);
    _limpiarError();

    try {
      await _cargarDetalleInterno(id);
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> cancelarReserva(int id, {String? motivo}) async {
    _setCargando(true);
    _limpiarError();

    try {
      final Sesion sesion = _leerSesionAutenticada();
      await _repoReservas.cancelar(id, sesion.token, motivo: motivo);
      // Un único ciclo de carga: recarga lista y detalle sin parpadeos de
      // spinner ni vaciar el detalle por el camino.
      await _cargarReservasInterno();
      await _cargarDetalleInterno(id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mensajeError(e));
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<void> _cargarReservasInterno() async {
    final Sesion sesion = _leerSesionCliente();
    _reservas = await _repoReservas.listarPorCliente(
      sesion.clienteId ?? 0,
      sesion.token,
    );
    _reservas = _reservas.where(_reservaEsValida).toList(growable: false);
    _totalesReservas = _calcularTotalesDesdeLineas();
  }

  Future<void> _cargarDetalleInterno(int id) async {
    final Sesion sesion = _leerSesionAutenticada();
    final Reserva reserva = await _repoReservas.obtenerPorId(id, sesion.token);
    final List<ReservaServicio> detalles = await _repoReservas.obtenerDetalles(
      id,
      sesion.token,
    );
    _detalle = _crearDetalle(reserva, detalles);
  }

  Future<void> recargar() => cargarReservasCliente();

  bool _reservaEsValida(Reserva reserva) {
    return reserva.id != null && reserva.horaInicio.trim().isNotEmpty;
  }

  List<DtoReservaCliente> _crearDtos() {
    final List<Reserva> ordenadas = List<Reserva>.from(_reservas)
      ..sort((a, b) {
        final int fecha = a.fecha.compareTo(b.fecha);
        return fecha == 0 ? a.horaInicio.compareTo(b.horaInicio) : fecha;
      });
    return ordenadas.map(_crearDto).toList(growable: false);
  }

  DtoReservaCliente _crearDto(Reserva reserva) {
    final DateTime inicio = _combinarFechaHora(
      reserva.fecha,
      reserva.horaInicio,
    );
    return DtoReservaCliente(
      id: reserva.id ?? 0,
      estado: _estadoPresentacion(reserva.estado),
      nombreServicio: _nombreReserva(reserva),
      metaFechaHora: _formatearFechaHora(inicio),
      precioTexto: _formatoPrecio.format(_totalesReservas[reserva.id] ?? 0),
      esProxima:
          inicio.isAfter(DateTime.now()) &&
          reserva.estado != EstadoReserva.cancelada &&
          reserva.estado != EstadoReserva.completada,
    );
  }

  DtoDetalleReservaCliente _crearDetalle(
    Reserva reserva,
    List<ReservaServicio> detalles,
  ) {
    final ReservaServicio? primero = detalles.isEmpty ? null : detalles.first;
    final double total = detalles.fold<double>(
      0,
      (suma, detalle) =>
          suma + detalle.precioUnitario * (detalle.cantidad ?? 1),
    );
    final int duracion = detalles.fold<int>(
      0,
      (suma, detalle) => suma + _duracionDetalle(detalle),
    );
    final String profesional =
        primero?.nombreEmpleado ?? 'Asignación automática';

    return DtoDetalleReservaCliente(
      id: reserva.id ?? 0,
      estado: _estadoPresentacion(reserva.estado),
      servicio: detalles.isEmpty
          ? _nombreReserva(reserva)
          : detalles
                .map((detalle) => detalle.nombreServicio ?? 'Servicio')
                .join(', '),
      profesionalNombre: profesional,
      profesionalRol: 'Profesional',
      profesionalIniciales: _crearIniciales(profesional),
      fechaTexto: _formatoFechaCompleta(reserva.fecha),
      horaTexto: reserva.horaInicio,
      duracionTexto: '${duracion == 0 ? 0 : duracion} min',
      precioTotalTexto: _formatoPrecio.format(total),
      notas: reserva.notas,
      motivo: reserva.motivo,
      puedeCancelar:
          reserva.estado == EstadoReserva.pendiente ||
          reserva.estado == EstadoReserva.confirmada,
      detalles: detalles.map(_crearLineaDetalle).toList(growable: false),
    );
  }

  DtoLineaDetalleReservaCliente _crearLineaDetalle(ReservaServicio detalle) {
    final int duracion = _duracionDetalle(detalle);
    return DtoLineaDetalleReservaCliente(
      servicio: detalle.nombreServicio ?? 'Servicio',
      profesional: detalle.nombreEmpleado ?? 'Asignación automática',
      horaTexto:
          '${_formatearHora(detalle.horaInicio)} - '
          '${_formatearHora(detalle.horaFin)}',
      duracionTexto: '$duracion min',
      precioTexto: _formatoPrecio.format(
        detalle.precioUnitario * (detalle.cantidad ?? 1),
      ),
      cantidadTexto: _cantidadTexto(detalle.cantidad),
      estadoTexto: _estadoDetalleTexto(detalle),
    );
  }

  String _nombreReserva(Reserva reserva) {
    return reserva.servicioIds.length == 1
        ? '1 servicio'
        : '${reserva.servicioIds.length} servicios';
  }

  int _duracionDetalle(ReservaServicio detalle) {
    final DateTime inicio = _parsearHora(detalle.horaInicio);
    final DateTime fin = _parsearHora(detalle.horaFin);
    return fin.difference(inicio).inMinutes;
  }

  Map<int, double> _calcularTotalesDesdeLineas() {
    final Map<int, double> totales = <int, double>{};
    for (final Reserva reserva in _reservas) {
      final int? id = reserva.id;
      if (id == null) continue;
      totales[id] = _calcularTotal(reserva.lineas);
    }
    return totales;
  }

  double _calcularTotal(List<ReservaServicio> detalles) {
    return detalles.fold<double>(
      0,
      (suma, detalle) =>
          suma + detalle.precioUnitario * (detalle.cantidad ?? 1),
    );
  }

  String? _cantidadTexto(int? cantidad) {
    if (cantidad == null || cantidad <= 1) return null;
    return 'Cantidad: $cantidad';
  }

  String? _estadoDetalleTexto(ReservaServicio detalle) {
    final estado = detalle.estado;
    if (estado == null) return null;
    return switch (estado.name) {
      'activo' => 'Activo',
      'cancelado' => 'Cancelado',
      _ => estado.name,
    };
  }

  DateTime _combinarFechaHora(DateTime fecha, String hora) {
    final List<String> partes = hora.split(':');
    final int horaValor = int.tryParse(partes.first) ?? 0;
    final int minutoValor = partes.length > 1
        ? int.tryParse(partes[1]) ?? 0
        : 0;
    return DateTime(fecha.year, fecha.month, fecha.day, horaValor, minutoValor);
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

  String _formatearFechaHora(DateTime fecha) {
    return '${_capitalizar(_formatoFecha.format(fecha))} · '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')} h';
  }

  String _formatearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) return hora;
    return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
  }

  String _formatoFechaCompleta(DateTime fecha) {
    return _capitalizar(DateFormat('EEE, d MMM yyyy', 'es_ES').format(fecha));
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto.substring(0, 1).toUpperCase()}${texto.substring(1)}';
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) return 'AA';
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) return primera;
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  EstadoReservaPresentacion _estadoPresentacion(EstadoReserva? estado) {
    return switch (estado) {
      EstadoReserva.confirmada => EstadoReservaPresentacion.confirmada,
      EstadoReserva.cancelada => EstadoReservaPresentacion.cancelada,
      EstadoReserva.completada => EstadoReservaPresentacion.completada,
      EstadoReserva.pendiente || null => EstadoReservaPresentacion.pendiente,
    };
  }

  Sesion _leerSesionCliente() {
    final Sesion sesion = _leerSesionAutenticada();
    if (sesion.clienteId == null) {
      throw StateError('La sesión no tiene cliente asociado.');
    }
    return sesion;
  }

  Sesion _leerSesionAutenticada() {
    final Sesion? sesion = _autenticacion.obtenerSesion();
    if (sesion == null || sesion.token.isEmpty) {
      throw StateError('Sesión no disponible.');
    }
    return sesion;
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }

  void _setError(String mensaje) {
    _error = mensaje;
    notifyListeners();
  }

  void _limpiarError() {
    _error = null;
  }
}
