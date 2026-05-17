import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/login_respuesta.dart';
import 'package:citaria_frontend/data/models/peticion_login.dart';
import 'package:citaria_frontend/data/models/registro.dart';
import 'package:citaria_frontend/data/models/usuario.dart';

class RepoAuth {
  RepoAuth(this._api);

  final CitariaApi _api;

  Future<LoginRespuesta> login(PeticionLogin peticion) async {
    try {
      final Object? json = await _api.post(
        '/auth/login',
        cuerpo: peticion.toJson(),
      );
      return LoginRespuesta.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<LoginRespuesta> registro(Registro registro) async {
    try {
      final Object? json = await _api.post(
        '/auth/registro',
        cuerpo: registro.toJson(),
      );
      return LoginRespuesta.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Usuario> obtenerUsuarioActual(String token) async {
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
}
