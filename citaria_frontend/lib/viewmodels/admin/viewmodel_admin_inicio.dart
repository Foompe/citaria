import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/enums/estado_reserva_servicio.dart';
import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoInicioAdmin {
  const DtoEmpleadoInicioAdmin({
    required this.id,
    required this.nombre,
    required this.fotoUrl,
  });

  final int id;
  final String nombre;
  final String? fotoUrl;
}

@immutable
class DtoReservaInicioAdmin {
  const DtoReservaInicioAdmin({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.horaInicioH,
    required this.horaInicioM,
    required this.duracionMin,
    required this.empleadoId,
    required this.estado,
  });

  final int id;
  final String cliente;
  final String servicio;
  final int horaInicioH;
  final int horaInicioM;
  final int duracionMin;
  final int empleadoId;
  final EstadoReserva estado;
}

class ViewModelAdminInicio extends ViewModelAdminBase {
  ViewModelAdminInicio({
    required RepoEmpleados repoEmpleados,
    required RepoReservas repoReservas,
    required super.autenticacion,
  }) : _repoEmpleados = repoEmpleados,
       _repoReservas = repoReservas;

  final RepoEmpleados _repoEmpleados;
  final RepoReservas _repoReservas;

  List<DtoEmpleadoInicioAdmin> _empleados = const <DtoEmpleadoInicioAdmin>[];
  List<DtoReservaInicioAdmin> _reservas = const <DtoReservaInicioAdmin>[];
  int _reservasPendientes = 0;
  DateTime _fechaSeleccionada = DateTime.now();

  List<DtoEmpleadoInicioAdmin> get empleados => _empleados;
  List<DtoReservaInicioAdmin> get reservas => _reservas;
  int get reservasPendientes => _reservasPendientes;
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  Future<void> cargarInicio() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final DateTime fecha = _soloFecha(_fechaSeleccionada);
      final List<Empleado> empleados = await _repoEmpleados.listarTodos(token);
      final List<Reserva> reservas = await _repoReservas.listarConFiltros(
        fecha,
        <EstadoReserva>[EstadoReserva.pendiente, EstadoReserva.confirmada],
        token,
      );

      _empleados =
          empleados
              .where((empleado) => empleado.id != null)
              .where((empleado) => empleado.anonimizadoAt == null)
              .where((empleado) => empleado.activo ?? true)
              .map(_crearEmpleado)
              .toList(growable: false)
            ..sort((a, b) => a.nombre.compareTo(b.nombre));
      _reservasPendientes = reservas
          .where((reserva) => reserva.estado == EstadoReserva.pendiente)
          .length;
      _reservas = await _crearReservas(reservas, token);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarInicio();
  }

  Future<void> cambiarFecha(DateTime fecha) {
    _fechaSeleccionada = _soloFecha(fecha);
    return cargarInicio();
  }

  DtoEmpleadoInicioAdmin _crearEmpleado(Empleado empleado) {
    final String nombreCompleto = _crearNombreCompleto(
      empleado.nombre,
      empleado.apellidos,
    );
    return DtoEmpleadoInicioAdmin(
      id: empleado.id ?? 0,
      nombre: nombreCompleto,
      fotoUrl: _textoOpcional(empleado.fotoUrl),
    );
  }

  Future<List<DtoReservaInicioAdmin>> _crearReservas(
    List<Reserva> reservas,
    String token,
  ) async {
    final List<DtoReservaInicioAdmin> resultado = <DtoReservaInicioAdmin>[];

    // Solo reservas con id; sus detalles se piden en paralelo (antes era una
    // petición por reserva en serie: N+1 que ralentizaba el inicio).
    final List<Reserva> validas = reservas
        .where((reserva) => reserva.id != null)
        .toList(growable: false);
    final List<List<ReservaServicio>> detallesPorReserva = await Future.wait(
      validas.map((reserva) => _repoReservas.obtenerDetalles(reserva.id!, token)),
    );

    for (int i = 0; i < validas.length; i++) {
      final Reserva reserva = validas[i];
      final List<ReservaServicio> detalles = detallesPorReserva[i];
      final EstadoReserva estado = reserva.estado ?? EstadoReserva.pendiente;
      final Iterable<ReservaServicio> activos = detalles.where(
        (detalle) => detalle.estado != EstadoReservaServicio.cancelado,
      );

      if (activos.isEmpty) {
        final DtoReservaInicioAdmin? fallback = _crearReservaFallback(
          reserva,
          estado,
        );
        if (fallback != null) {
          resultado.add(fallback);
        }
        continue;
      }

      for (final ReservaServicio detalle in activos) {
        resultado.add(_crearReservaDesdeDetalle(reserva, detalle, estado));
      }
    }

    resultado.sort(_compararReservas);
    return resultado;
  }

  DtoReservaInicioAdmin _crearReservaDesdeDetalle(
    Reserva reserva,
    ReservaServicio detalle,
    EstadoReserva estado,
  ) {
    final _HoraInicio horaInicio = _parsearHora(detalle.horaInicio);
    return DtoReservaInicioAdmin(
      id: reserva.id ?? 0,
      cliente: _textoConFallback(reserva.nombreCliente, 'Cliente'),
      servicio: _textoConFallback(detalle.nombreServicio, 'Servicio'),
      horaInicioH: horaInicio.hora,
      horaInicioM: horaInicio.minuto,
      duracionMin: _duracionMinutos(detalle.horaInicio, detalle.horaFin),
      empleadoId: detalle.empleadoId,
      estado: estado,
    );
  }

  DtoReservaInicioAdmin? _crearReservaFallback(
    Reserva reserva,
    EstadoReserva estado,
  ) {
    final int? empleadoId = reserva.empleadoId;
    if (empleadoId == null || reserva.horaInicio.isEmpty) {
      return null;
    }
    final _HoraInicio horaInicio = _parsearHora(reserva.horaInicio);
    return DtoReservaInicioAdmin(
      id: reserva.id ?? 0,
      cliente: _textoConFallback(reserva.nombreCliente, 'Cliente'),
      servicio: _resumenServicios(reserva.servicioIds.length),
      horaInicioH: horaInicio.hora,
      horaInicioM: horaInicio.minuto,
      duracionMin: 30,
      empleadoId: empleadoId,
      estado: estado,
    );
  }

  int _compararReservas(DtoReservaInicioAdmin a, DtoReservaInicioAdmin b) {
    final int empleado = a.empleadoId.compareTo(b.empleadoId);
    if (empleado != 0) {
      return empleado;
    }
    final int hora = a.horaInicioH.compareTo(b.horaInicioH);
    if (hora != 0) {
      return hora;
    }
    return a.horaInicioM.compareTo(b.horaInicioM);
  }

  int _duracionMinutos(String inicio, String fin) {
    final _HoraInicio horaInicio = _parsearHora(inicio);
    final _HoraInicio horaFin = _parsearHora(fin);
    final int minutos =
        (horaFin.hora * 60 + horaFin.minuto) -
        (horaInicio.hora * 60 + horaInicio.minuto);
    return minutos <= 0 ? 30 : minutos;
  }

  _HoraInicio _parsearHora(String hora) {
    final List<String> partes = hora.split(':');
    return _HoraInicio(
      hora: int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 0,
      minuto: int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0,
    );
  }

  DateTime _soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  String _crearNombreCompleto(String nombre, String apellidos) {
    final String completo = '$nombre $apellidos'.trim();
    return completo.isEmpty ? 'Empleado' : completo;
  }

  String _resumenServicios(int total) {
    if (total <= 0) {
      return 'Servicio';
    }
    return total == 1 ? '1 servicio' : '$total servicios';
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }
}

@immutable
class _HoraInicio {
  const _HoraInicio({required this.hora, required this.minuto});

  final int hora;
  final int minuto;
}
