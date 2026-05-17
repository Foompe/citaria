import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/enums/rol_usuario.dart';
import 'package:citaria_frontend/data/models/peticion_usuario.dart';
import 'package:citaria_frontend/data/models/usuario.dart';

class RepoUsuarios {
  RepoUsuarios(this._api);

  final CitariaApi _api;

  Future<List<Usuario>> listarTodos(String token) async {
    try {
      final Object? json = await _api.get('/api/usuarios', token: token);
      return (json as List)
          .map((elemento) => Usuario.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Usuario>> listarPorRol(RolUsuario rol, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/usuarios/rol/${rol.toJson()}',
        token: token,
      );
      return (json as List)
          .map((elemento) => Usuario.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Usuario> obtenerActual(String token) async {
    try {
      final Object? json = await _api.get('/api/usuarios/me', token: token);
      return Usuario.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Usuario> obtenerPorId(int id, String token) async {
    try {
      final Object? json = await _api.get('/api/usuarios/$id', token: token);
      return Usuario.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Usuario> crear(PeticionUsuario peticion, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/usuarios',
        cuerpo: peticion.toJson(),
        token: token,
      );
      return Usuario.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Usuario> actualizar(
    int id,
    PeticionUsuario peticion,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/usuarios/$id',
        cuerpo: peticion.toJson(),
        token: token,
      );
      return Usuario.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminar(int id, String token) async {
    try {
      await _api.delete('/api/usuarios/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
