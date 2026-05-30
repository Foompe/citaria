import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class DtoReservaCalendario {
  const DtoReservaCalendario({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String cliente;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
}

/// ViewModel del calendario admin.
///
/// Carga las reservas del mes en una sola petición y las agrupa por día.
/// Aplica la regla de visibilidad por fecha:
/// - Día de hoy en adelante: pendientes y confirmadas.
/// - Días pasados: canceladas y completadas.
///
/// La selección de un día no genera peticiones: lee del mapa ya cargado.
class ViewModelAdminCalendario extends ViewModelAdminBase {
  ViewModelAdminCalendario({
    required RepoReservas repoReservas,
    required super.autenticacion,
    DateTime? mesInicial,
  }) : _repoReservas = repoReservas,
       _mesActual = _normalizarMes(mesInicial ?? DateTime.now());

  final RepoReservas _repoReservas;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );

  DateTime _mesActual;
  Map<int, List<DtoReservaCalendario>> _reservasPorDia = const {};

  DateTime get mesActual => _mesActual;

  List<DtoReservaCalendario> reservasPorDia(int dia) {
    return _reservasPorDia[dia] ?? const <DtoReservaCalendario>[];
  }

  int contarPorDia(int dia) => _reservasPorDia[dia]?.length ?? 0;

  Future<void> cargarMes(DateTime mes) async {
    _mesActual = _normalizarMes(mes);
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final DateTime primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
      final DateTime ultimoDia = DateTime(
        _mesActual.year,
        _mesActual.month + 1,
        0,
      );
      final List<Reserva> reservas = await _repoReservas.listarAdminPorFecha(
        primerDia,
        ultimoDia,
        null,
        token,
      );
      _reservasPorDia = _agruparPorDia(reservas);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> mesAnterior() {
    return cargarMes(DateTime(_mesActual.year, _mesActual.month - 1));
  }

  Future<void> mesSiguiente() {
    return cargarMes(DateTime(_mesActual.year, _mesActual.month + 1));
  }

  Future<void> refrescar() {
    return cargarMes(_mesActual);
  }

  Map<int, List<DtoReservaCalendario>> _agruparPorDia(List<Reserva> reservas) {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final Map<int, List<DtoReservaCalendario>> agrupadas =
        <int, List<DtoReservaCalendario>>{};
    for (final Reserva reserva in reservas) {
      if (!_cumpleRegla(reserva, hoy)) continue;
      agrupadas
          .putIfAbsent(reserva.fecha.day, () => <DtoReservaCalendario>[])
          .add(_crearDto(reserva));
    }
    return agrupadas;
  }

  bool _cumpleRegla(Reserva reserva, DateTime hoy) {
    final DateTime fecha = DateTime(
      reserva.fecha.year,
      reserva.fecha.month,
      reserva.fecha.day,
    );
    final EstadoReserva estado = reserva.estado ?? EstadoReserva.pendiente;
    if (fecha.isBefore(hoy)) {
      return estado == EstadoReserva.cancelada ||
          estado == EstadoReserva.completada;
    }
    return estado == EstadoReserva.pendiente ||
        estado == EstadoReserva.confirmada;
  }

  DtoReservaCalendario _crearDto(Reserva reserva) {
    final List<ReservaServicio> lineas = reserva.lineas;
    final ReservaServicio? primeraLinea = lineas.isEmpty ? null : lineas.first;
    return DtoReservaCalendario(
      id: reserva.id.toString(),
      cliente: _textoConFallback(reserva.nombreCliente, 'Cliente sin nombre'),
      servicio: lineas.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : lineas.map((l) => l.nombreServicio ?? 'Servicio').join(', '),
      empleado: _textoConFallback(
        primeraLinea?.nombreEmpleado,
        'Sin empleado asignado',
      ),
      hora: reserva.horaInicio.isEmpty
          ? '--:--'
          : _formatearHora(reserva.horaInicio),
      precio: _formatoPrecio.format(_calcularTotal(lineas)),
      estado: reserva.estado ?? EstadoReserva.pendiente,
    );
  }

  double _calcularTotal(List<ReservaServicio> lineas) {
    return lineas.fold<double>(
      0,
      (suma, l) => suma + l.precioUnitario * (l.cantidad ?? 1),
    );
  }

  String _resumenServicios(int total) {
    return total == 1 ? '1 servicio' : '$total servicios';
  }

  String _formatearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) return hora;
    return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
  }

  String _textoConFallback(String? texto, String fallback) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  static DateTime _normalizarMes(DateTime fecha) {
    return DateTime(fecha.year, fecha.month);
  }
}
