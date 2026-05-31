import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/models/pagina_reservas.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/utils/formato_hora.dart';
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
    required this.fotoUrlEmpleado,
    required this.horarioTexto,
    required this.duracionTexto,
    required this.precioTexto,
    required this.estadoTexto,
  });

  final String servicio;
  final String empleado;
  final String? fotoUrlEmpleado;
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
    required this.fotoUrlCliente,
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.fotoUrlEmpleado,
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
  final String? fotoUrlCliente;
  final String servicio;
  final String duracion;
  final String empleado;
  final String? fotoUrlEmpleado;
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
    required RepoEmpleados repoEmpleados,
    required super.autenticacion,
    FiltroAdminReservas filtroInicial = FiltroAdminReservas.hoy,
  }) : _repoReservas = repoReservas,
       _repoClientes = repoClientes,
       _repoEmpleados = repoEmpleados,
       _filtroActivo = filtroInicial;

  final RepoReservas _repoReservas;
  final RepoClientes _repoClientes;
  final RepoEmpleados _repoEmpleados;
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
  FiltroAdminReservas _filtroActivo;
  DtoDetalleReservaAdmin? _detalle;
  EstadoReserva? _estadoPendiente;
  int _paginaActual = 0;
  bool _hayMasPaginas = false;

  FiltroAdminReservas get filtroActivo => _filtroActivo;
  DtoDetalleReservaAdmin? get detalle => _detalle;
  EstadoReserva? get estadoPendiente => _estadoPendiente;
  bool get hayMasPaginas => _hayMasPaginas;

  void seleccionarEstadoPendiente(EstadoReserva estado) {
    _estadoPendiente = estado == _detalle?.estado ? null : estado;
    notifyListeners();
  }

  void descartarEstadoPendiente() {
    _estadoPendiente = null;
    notifyListeners();
  }

  List<DtoReservaAdmin> get reservas {
    return _reservas.map(_crearDto).toList(growable: false);
  }

  Future<void> cargarReservas() async {
    iniciarCarga();
    _paginaActual = 0;
    _hayMasPaginas = false;

    try {
      final String token = leerTokenObligatorio();
      _reservas = await _cargarPorFiltro(token, numeroPagina: 0);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarMas() async {
    if (!_hayMasPaginas) return;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Reserva> nuevas = await _cargarPorFiltro(
        token,
        numeroPagina: _paginaActual + 1,
      );
      _paginaActual++;
      _reservas = <Reserva>[..._reservas, ...nuevas];
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

  void seleccionarFiltro(FiltroAdminReservas filtro) {
    if (_filtroActivo == filtro) return;
    _filtroActivo = filtro;
    cargarReservas();
  }

  Future<void> cargarDetalleReserva(int id) async {
    _detalle = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Reserva reserva = await _repoReservas.obtenerPorId(id, token);
      final resultados = await Future.wait(<Future<Object?>>[
        _obtenerClienteSiEsPosible(reserva, token),
        _cargarFotosEmpleados(reserva.lineas, token),
      ]);
      final cliente = resultados[0] as Cliente?;
      final fotosEmpleados = resultados[1] as Map<int, String?>;
      _detalle = _crearDetalle(reserva, reserva.lineas, cliente, fotosEmpleados);
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
      await _recargarDetalleTrasAccion(id);
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
      await _recargarDetalleTrasAccion(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<List<Reserva>> _cargarPorFiltro(
    String token, {
    required int numeroPagina,
  }) async {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);

    return switch (_filtroActivo) {
      FiltroAdminReservas.hoy => _repoReservas.listarAdminPorFecha(
        hoy,
        hoy,
        <EstadoReserva>[EstadoReserva.pendiente, EstadoReserva.confirmada],
        token,
      ),
      FiltroAdminReservas.semana => _repoReservas.listarAdminPorFecha(
        hoy,
        _finDeSemana(hoy),
        <EstadoReserva>[EstadoReserva.pendiente, EstadoReserva.confirmada],
        token,
      ),
      FiltroAdminReservas.pendientes =>
        _cargarPaginado(EstadoReserva.pendiente, numeroPagina, token),
      FiltroAdminReservas.confirmadas =>
        _cargarPaginado(EstadoReserva.confirmada, numeroPagina, token),
      FiltroAdminReservas.canceladas =>
        _cargarPaginado(EstadoReserva.cancelada, numeroPagina, token),
    };
  }

  Future<List<Reserva>> _cargarPaginado(
    EstadoReserva estado,
    int numeroPagina,
    String token,
  ) async {
    final PaginaReservas resultado = await _repoReservas.listarAdminPorEstado(
      estado,
      numeroPagina,
      token,
    );
    _hayMasPaginas = !resultado.last;
    return resultado.content;
  }

  DtoReservaAdmin _crearDto(Reserva reserva) {
    final List<ReservaServicio> lineas = reserva.lineas;
    final ReservaServicio? primeraLinea = lineas.isEmpty ? null : lineas.first;
    return DtoReservaAdmin(
      id: reserva.id.toString(),
      cliente: _textoConFallback(reserva.nombreCliente, 'Cliente sin nombre'),
      servicio: lineas.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : lineas
                .map((l) => l.nombreServicio ?? 'Servicio')
                .join(', '),
      empleado: _textoConFallback(
        primeraLinea?.nombreEmpleado,
        'Sin empleado asignado',
      ),
      fechaHoraTexto: '${_formatoFecha.format(reserva.fecha)} · '
          '${reserva.horaInicio.isEmpty ? '--:--' : formatearHoraHm(reserva.horaInicio)}',
      precio: _formatoPrecio.format(_calcularTotal(lineas)),
      estado: reserva.estado ?? EstadoReserva.pendiente,
    );
  }

  DtoDetalleReservaAdmin _crearDetalle(
    Reserva reserva,
    List<ReservaServicio> detalles,
    Cliente? cliente,
    Map<int, String?> fotosEmpleados,
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
      fotoUrlCliente: _textoOpcional(cliente?.fotoUrl),
      servicio: detalles.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : detalles
                .map((detalle) => detalle.nombreServicio ?? 'Servicio')
                .join(', '),
      duracion: '$duracion min',
      empleado: empleado,
      fotoUrlEmpleado: primerDetalle != null
          ? fotosEmpleados[primerDetalle.empleadoId]
          : null,
      fecha: _capitalizar(_formatoFechaCompleta.format(reserva.fecha)),
      hora: _textoConFallback(reserva.horaInicio, '--:--'),
      total: _formatoPrecio.format(_calcularTotal(detalles)),
      observaciones: _textoOpcional(reserva.notas),
      motivo: _textoOpcional(reserva.motivo),
      puedeConfirmar: reserva.estado == EstadoReserva.pendiente,
      puedeCancelar:
          reserva.estado == EstadoReserva.pendiente ||
          reserva.estado == EstadoReserva.confirmada,
      puedeCambiarEstado: reserva.estado == EstadoReserva.pendiente ||
          reserva.estado == EstadoReserva.confirmada,
      lineas: detalles
          .map((d) => _crearLineaDetalle(d, fotosEmpleados))
          .toList(growable: false),
    );
  }

  DtoLineaDetalleReservaAdmin _crearLineaDetalle(
    ReservaServicio detalle,
    Map<int, String?> fotosEmpleados,
  ) {
    final int duracion = _duracionDetalle(detalle);
    return DtoLineaDetalleReservaAdmin(
      servicio: _textoConFallback(detalle.nombreServicio, 'Servicio'),
      empleado: _textoConFallback(
        detalle.nombreEmpleado,
        'Sin empleado asignado',
      ),
      fotoUrlEmpleado: fotosEmpleados[detalle.empleadoId],
      horarioTexto:
          '${formatearHoraHm(detalle.horaInicio)} - '
          '${formatearHoraHm(detalle.horaFin)}',
      duracionTexto: '$duracion min',
      precioTexto: _formatoPrecio.format(
        detalle.precioUnitario * (detalle.cantidad ?? 1),
      ),
      estadoTexto: _estadoDetalleTexto(detalle),
    );
  }

  Future<Map<int, String?>> _cargarFotosEmpleados(
    List<ReservaServicio> detalles,
    String token,
  ) async {
    final Set<int> ids = detalles.map((d) => d.empleadoId).toSet();
    final Iterable<Future<MapEntry<int, String?>>> futures = ids.map((id) async {
      try {
        final Empleado emp = await _repoEmpleados.obtenerPorId(id, token);
        return MapEntry(id, emp.fotoUrl);
      } catch (_) {
        return MapEntry<int, String?>(id, null);
      }
    });
    return Map.fromEntries(await Future.wait(futures));
  }

  Future<void> _recargarDetalleTrasAccion(int id) async {
    final String token = leerTokenObligatorio();
    final Reserva reserva = await _repoReservas.obtenerPorId(id, token);
    final resultados = await Future.wait(<Future<Object?>>[
      _obtenerClienteSiEsPosible(reserva, token),
      _cargarFotosEmpleados(reserva.lineas, token),
    ]);
    final cliente = resultados[0] as Cliente?;
    final fotosEmpleados = resultados[1] as Map<int, String?>;
    _estadoPendiente = null;
    _detalle = _crearDetalle(reserva, reserva.lineas, cliente, fotosEmpleados);
    notifyListeners();
  }

  DateTime _finDeSemana(DateTime hoy) {
    final int diasHastaFinSemana = DateTime.sunday - hoy.weekday;
    return hoy.add(Duration(days: diasHastaFinSemana));
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

  String _resumenServicios(int total) {
    return total == 1 ? '1 servicio' : '$total servicios';
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

  Future<Cliente?> _obtenerClienteSiEsPosible(
    Reserva reserva,
    String token,
  ) async {
    final int? clienteId = reserva.clienteId;
    if (clienteId == null) return null;
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
    if (apellidosLimpios == null) return nombre;
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
    if (texto.isEmpty) return texto;
    return '${texto.substring(0, 1).toUpperCase()}${texto.substring(1)}';
  }
}
