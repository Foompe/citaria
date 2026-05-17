import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/estadistica_item.dart';
import 'package:citaria_frontend/data/models/estadistica_mes.dart';
import 'package:citaria_frontend/data/models/resumen_estadistica.dart';

class RepoEstadisticas {
  RepoEstadisticas(this._api);

  final CitariaApi _api;

  Future<ResumenEstadistica> obtenerResumen(String token) async {
    try {
      final Object? json = await _api.get(
        '/api/estadisticas/resumen',
        token: token,
      );
      return ResumenEstadistica.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaMes>> clientesNuevosVsRecurrentes(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas(
          '/api/estadisticas/clientes/nuevos-vs-recurrentes',
          desde,
          hasta,
        ),
        token: token,
      );
      return _mapearMeses(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaMes>> fidelizacionClientes(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas('/api/estadisticas/clientes/fidelizacion', desde, hasta),
        token: token,
      );
      return _mapearMeses(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> reservasPorEmpleado(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas('/api/estadisticas/empleados/reservas', desde, hasta),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> importePorEmpleado(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas('/api/estadisticas/empleados/importe', desde, hasta),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> cancelacionesPorEmpleado(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas(
          '/api/estadisticas/empleados/cancelaciones',
          desde,
          hasta,
        ),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> serviciosMasSolicitados(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas(
          '/api/estadisticas/servicios/mas-solicitados',
          desde,
          hasta,
        ),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> importePorServicio(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas('/api/estadisticas/servicios/importe', desde, hasta),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EstadisticaItem>> cancelacionesPorServicio(
    DateTime desde,
    DateTime hasta,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        _rutaConFechas(
          '/api/estadisticas/servicios/cancelaciones',
          desde,
          hasta,
        ),
        token: token,
      );
      return _mapearItems(json);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  List<EstadisticaMes> _mapearMeses(Object? json) {
    return (json as List)
        .map(
          (elemento) =>
              EstadisticaMes.fromJson(elemento as Map<String, dynamic>),
        )
        .toList();
  }

  List<EstadisticaItem> _mapearItems(Object? json) {
    return (json as List)
        .map(
          (elemento) =>
              EstadisticaItem.fromJson(elemento as Map<String, dynamic>),
        )
        .toList();
  }

  String _rutaConFechas(String ruta, DateTime desde, DateTime hasta) {
    return '$ruta?desde=${_formatearFecha(desde)}'
        '&hasta=${_formatearFecha(hasta)}';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }
}
