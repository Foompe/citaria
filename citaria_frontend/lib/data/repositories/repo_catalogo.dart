import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/servicio_skill.dart';
import 'package:citaria_frontend/data/models/skill.dart';

class RepoCatalogo {
  RepoCatalogo(this._api);

  final CitariaApi _api;

  Future<List<Servicio>> listarServicios(String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/servicios',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) => Servicio.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Servicio>> listarPorCategoria(
    int categoriaId,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/servicios/categoria/$categoriaId',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) => Servicio.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Servicio> obtenerServicioPorId(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/servicios/$id',
        token: token,
      );
      return Servicio.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Servicio> crearServicio(Servicio servicio, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/servicios',
        cuerpo: servicio.toJson(),
        token: token,
      );
      return Servicio.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Servicio> actualizarServicio(
    int id,
    Servicio servicio,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/catalogo/servicios/$id',
        cuerpo: servicio.toJson(),
        token: token,
      );
      return Servicio.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> subirImagenServicio(
    int id,
    List<int> bytes,
    String nombreFichero,
    String token,
  ) async {
    try {
      await _api.postMultipart(
        '/api/catalogo/servicios/$id/imagen',
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

  Future<void> desactivarServicio(int id, String token) async {
    try {
      await _api.delete('/api/catalogo/servicios/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<ServicioSkill>> obtenerSkillsServicio(
    int id,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/servicios/$id/skills',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                ServicioSkill.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ServicioSkill> asignarSkillServicio(
    int servicioId,
    int skillId,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/servicios/$servicioId/skills/$skillId',
        token: token,
      );
      return ServicioSkill.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarSkillServicio(
    int servicioId,
    int skillId,
    String token,
  ) async {
    try {
      await _api.delete(
        '/api/catalogo/servicios/$servicioId/skills/$skillId',
        token: token,
      );
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Categoria>> listarCategorias(String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/categorias',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) => Categoria.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Categoria> obtenerCategoriaPorId(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/categorias/$id',
        token: token,
      );
      return Categoria.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Categoria> crearCategoria(Categoria categoria, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/categorias',
        cuerpo: categoria.toJson(),
        token: token,
      );
      return Categoria.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Categoria> actualizarCategoria(
    int id,
    Categoria categoria,
    String token,
  ) async {
    try {
      final Object? json = await _api.put(
        '/api/catalogo/categorias/$id',
        cuerpo: categoria.toJson(),
        token: token,
      );
      return Categoria.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> desactivarCategoria(int id, String token) async {
    try {
      await _api.delete('/api/catalogo/categorias/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Skill>> listarSkills(String token) async {
    try {
      final Object? json = await _api.get('/api/catalogo/skills', token: token);
      return (json as List)
          .map((elemento) => Skill.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Skill> obtenerSkillPorId(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/skills/$id',
        token: token,
      );
      return Skill.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Skill> crearSkill(Skill skill, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/skills',
        cuerpo: skill.toJson(),
        token: token,
      );
      return Skill.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Skill> actualizarSkill(int id, Skill skill, String token) async {
    try {
      final Object? json = await _api.put(
        '/api/catalogo/skills/$id',
        cuerpo: skill.toJson(),
        token: token,
      );
      return Skill.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> desactivarSkill(int id, String token) async {
    try {
      await _api.delete('/api/catalogo/skills/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
