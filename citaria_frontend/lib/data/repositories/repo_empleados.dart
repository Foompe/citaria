import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/models/empleado_habilidad.dart';
import 'package:citaria_frontend/data/models/horario_empleado.dart';
import 'package:citaria_frontend/data/models/reserva.dart';

class RepoEmpleados {
  RepoEmpleados(this._api);

  final CitariaApi _api;

  Future<List<Empleado>> listarTodos(String token) async {
    try {
      final Object? json = await _api.get('/api/empleados', token: token);
      return (json as List)
          .map(
            (elemento) => Empleado.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Empleado> obtenerPorId(int id, String token) async {
    try {
      final Object? json = await _api.get('/api/empleados/$id', token: token);
      return Empleado.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Empleado> crear(Empleado empleado, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/empleados',
        cuerpo: empleado.toJson(),
        token: token,
      );
      return Empleado.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Empleado> actualizar(int id, Empleado empleado, String token) async {
    try {
      final Object? json = await _api.put(
        '/api/empleados/$id',
        cuerpo: empleado.toJson(),
        token: token,
      );
      return Empleado.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> subirFoto(
    int id,
    List<int> bytes,
    String nombreFichero,
    String token,
  ) async {
    try {
      await _api.postMultipart(
        '/api/empleados/$id/imagen',
        bytes: bytes,
        nombreFichero: nombreFichero,
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Reserva>> obtenerReservasActivas(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/empleados/$id/reservas-activas',
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

  Future<List<HorarioEmpleado>> obtenerHorarios(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/empleados/$id/horarios',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                HorarioEmpleado.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<HorarioEmpleado> crearHorario(
    int id,
    HorarioEmpleado horario,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/empleados/$id/horarios',
        cuerpo: horario.toJson(),
        token: token,
      );
      return HorarioEmpleado.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<HorarioEmpleado> actualizarHorario(
    int empId,
    int horarioId,
    HorarioEmpleado horario,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/empleados/$empId/horarios/$horarioId',
        cuerpo: horario.toJson(),
        token: token,
      );
      return HorarioEmpleado.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarHorario(int empId, int horarioId, String token) async {
    try {
      await _api.delete(
        '/api/empleados/$empId/horarios/$horarioId',
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<EmpleadoHabilidad>> obtenerHabilidades(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/empleados/$id/habilidades',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                EmpleadoHabilidad.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<EmpleadoHabilidad> asignarHabilidad(
    int empId,
    int habilidadId,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/empleados/$empId/habilidades/$habilidadId',
        token: token,
      );
      return EmpleadoHabilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarHabilidad(int empId, int habilidadId, String token) async {
    try {
      await _api.delete('/api/empleados/$empId/habilidades/$habilidadId', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
