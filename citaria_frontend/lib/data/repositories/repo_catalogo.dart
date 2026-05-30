import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/servicio_habilidad.dart';
import 'package:citaria_frontend/data/models/habilidad.dart';

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

  Future<List<ServicioHabilidad>> obtenerHabilidadesServicio(
    int id,
    String token,
  ) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/servicios/$id/habilidades',
        token: token,
      );
      return (json as List)
          .map(
            (elemento) =>
                ServicioHabilidad.fromJson(elemento as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<ServicioHabilidad> asignarHabilidadServicio(
    int servicioId,
    int habilidadId,
    String token,
  ) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/servicios/$servicioId/habilidades/$habilidadId',
        token: token,
      );
      return ServicioHabilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> eliminarHabilidadServicio(
    int servicioId,
    int habilidadId,
    String token,
  ) async {
    try {
      await _api.delete(
        '/api/catalogo/servicios/$servicioId/habilidades/$habilidadId',
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

  Future<List<Habilidad>> listarHabilidades(String token) async {
    try {
      final Object? json = await _api.get('/api/catalogo/habilidades', token: token);
      return (json as List)
          .map((elemento) => Habilidad.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Habilidad> obtenerHabilidadPorId(int id, String token) async {
    try {
      final Object? json = await _api.get(
        '/api/catalogo/habilidades/$id',
        token: token,
      );
      return Habilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Habilidad> crearHabilidad(Habilidad habilidad, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/catalogo/habilidades',
        cuerpo: habilidad.toJson(),
        token: token,
      );
      return Habilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Habilidad> actualizarHabilidad(int id, Habilidad habilidad, String token) async {
    try {
      final Object? json = await _api.put(
        '/api/catalogo/habilidades/$id',
        cuerpo: habilidad.toJson(),
        token: token,
      );
      return Habilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<void> desactivarHabilidad(int id, String token) async {
    try {
      await _api.delete('/api/catalogo/habilidades/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
