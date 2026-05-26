import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/pagina_reservas.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';

class RepoReservas {
  RepoReservas(this._api);

  final CitariaApi _api;

  Future<List<Reserva>> listarAdminPorFecha(
    DateTime fechaInicio,
    DateTime fechaFin,
    List<EstadoReserva>? estados,
    String token,
  ) async {
    try {
      final List<String> params = <String>[
        'fechaInicio=${_formatearFecha(fechaInicio)}',
        'fechaFin=${_formatearFecha(fechaFin)}',
        if (estados != null && estados.isNotEmpty)
          'estados=${estados.map((e) => e.toJson()).join(',')}',
      ];
      final String ruta = '/api/reservas/admin/fecha?${params.join('&')}';
      final Object? json = await _api.get(ruta, token: token);
      return (json as List)
          .map((e) => Reserva.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<PaginaReservas> listarAdminPorEstado(
    EstadoReserva estado,
    int pagina,
    String token, {
    int tamano = 20,
  }) async {
    try {
      final String ruta =
          '/api/reservas/admin/estado?estado=${estado.toJson()}'
          '&pagina=$pagina&tamano=$tamano';
      final Object? json = await _api.get(ruta, token: token);
      return PaginaReservas.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Reserva>> listarConFiltros(
    DateTime fecha,
    List<EstadoReserva>? estados,
    String token,
  ) async {
    try {
      final List<String> params = <String>[
        'fecha=${_formatearFecha(fecha)}',
        if (estados != null)
          'estados=${estados.map((estado) => estado.toJson()).join(',')}',
      ];
      final String ruta = '/api/reservas/filtros?${params.join('&')}';
      final Object? json = await _api.get(ruta, token: token);
      return (json as List)
          .map((elemento) => Reserva.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Reserva>> listarPorCliente(int clienteId, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/reservas/cliente/$clienteId',
        token: token,
      );
      return (json as List)
          .map((elemento) => Reserva.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Reserva> obtenerPorId(int id, String token) async {
    try {
      final Object? json = await _api.get('/api/reservas/$id', token: token);
      return Reserva.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Reserva> crear(int clienteId, Reserva reserva, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/reservas/cliente/$clienteId',
        cuerpo: reserva.toJson(),
        token: token,
      );
      return Reserva.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Reserva> actualizarEstado(
    int id,
    EstadoReserva estado,
    String token,
  ) async {
    try {
      final Object? json = await _api.patch(
        '/api/reservas/$id/estado/${estado.toJson()}',
        token: token,
      );
      return Reserva.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> cancelar(int id, String token, {String? motivo}) async {
    try {
      final String ruta = motivo == null
          ? '/api/reservas/$id/cancelar'
          : '/api/reservas/$id/cancelar'
                '?motivo=${Uri.encodeQueryComponent(motivo)}';
      await _api.patch(ruta, token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<ReservaServicio>> obtenerDetalles(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/reservas/$id/detalles',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                ReservaServicio.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ReservaServicio> agregarDetalle(
    int id,
    ReservaServicio detalle,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/reservas/$id/detalles',
        cuerpo: detalle.toJson(),
        token: token,
      );
      return ReservaServicio.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarDetalle(
    int reservaId,
    int detalleId,
    String token,
  ) async {
    try {
      await _api.delete(
        '/api/reservas/$reservaId/detalles/$detalleId',
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ReservaServicio> reasignarEmpleado(
    int reservaId,
    int detalleId,
    int empleadoId,
    String token,
  ) async {
    try {
      final Object? json = await _api.patch(
        '/api/reservas/$reservaId/detalles/$detalleId/empleado/$empleadoId',
        token: token,
      );
      return ReservaServicio.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }
}
