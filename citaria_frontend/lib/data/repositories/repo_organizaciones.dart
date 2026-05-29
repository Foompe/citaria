import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/cierre_organizacion.dart';
import 'package:citaria_frontend/data/models/configuracion_visual.dart';
import 'package:citaria_frontend/data/models/horario_organizacion.dart';
import 'package:citaria_frontend/data/models/organizacion.dart';
import 'package:citaria_frontend/data/models/organizacion_publica.dart';

class RepoOrganizaciones {
  RepoOrganizaciones(this._api);

  final CitariaApi _api;

  Future<List<OrganizacionPublica>> listarPublicas() async {
    try {
      final Object? json = await _api.get('/api/organizaciones/publico');
      return (json as List)
          .map(
            (elemento) =>
                OrganizacionPublica.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ConfiguracionVisual> obtenerConfiguracion(int id) async {
    try {
      final Object? json = await _api.get(
        '/api/organizaciones/$id/configuracion',
      );
      return ConfiguracionVisual.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Organizacion> obtenerPorId(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/organizaciones/$id',
        token: token,
      );
      return Organizacion.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Organizacion> actualizar(
    int id,
    Organizacion organizacion,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/organizaciones/$id',
        cuerpo: organizacion.toJson(),
        token: token,
      );
      return Organizacion.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ConfiguracionVisual> actualizarConfiguracion(
    int id,
    ConfiguracionVisual configuracion,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/organizaciones/$id/configuracion',
        cuerpo: configuracion.toJson(),
        token: token,
      );
      return ConfiguracionVisual.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<HorarioOrganizacion>> obtenerHorarios(
    int id,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        '/api/organizaciones/$id/horarios',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                HorarioOrganizacion.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<HorarioOrganizacion> crearHorario(
    int id,
    HorarioOrganizacion horario,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/organizaciones/$id/horarios',
        cuerpo: horario.toJson(),
        token: token,
      );
      return HorarioOrganizacion.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<HorarioOrganizacion> actualizarHorario(
    int orgId,
    int horarioId,
    HorarioOrganizacion horario,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/organizaciones/$orgId/horarios/$horarioId',
        cuerpo: horario.toJson(),
        token: token,
      );
      return HorarioOrganizacion.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarHorario(int orgId, int horarioId, String token) async {
    try {
      await _api.delete(
        '/api/organizaciones/$orgId/horarios/$horarioId',
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<CierreOrganizacion>> obtenerCierres(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/organizaciones/$id/cierres',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                CierreOrganizacion.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<int> contarReservasActivasEnFecha(
    int id,
    DateTime fecha,
    String token,
  ) async {
    try {
      final String fechaStr =
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}';
      final Object? json = await _api.get(
        '/api/organizaciones/$id/cierres/preview?fecha=$fechaStr',
        token: token,
      );
      return (json as num).toInt();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<CierreOrganizacion> crearCierre(
    int id,
    CierreOrganizacion cierre,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/organizaciones/$id/cierres',
        cuerpo: cierre.toJson(),
        token: token,
      );
      return CierreOrganizacion.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarCierre(int orgId, int cierreId, String token) async {
    try {
      await _api.delete(
        '/api/organizaciones/$orgId/cierres/$cierreId',
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
