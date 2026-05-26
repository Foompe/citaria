import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/pagina_clientes.dart';

class RepoClientes {
  RepoClientes(this._api);

  final CitariaApi _api;

  Future<PaginaClientes> listarAdminPaginado(
    String? busqueda,
    int pagina,
    String token, {
    int tamano = 20,
  }) async {
    try {
      final List<String> params = <String>[
        'pagina=$pagina',
        'tamano=$tamano',
        if (busqueda != null && busqueda.isNotEmpty)
          'busqueda=${Uri.encodeQueryComponent(busqueda)}',
      ];
      final String ruta = '/api/clientes/admin?${params.join('&')}';
      final Object? json = await _api.get(ruta, token: token);
      return PaginaClientes.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<List<Cliente>> buscar(
    String token, {
    String? dni,
    String? email,
    String? telefono,
  }) async {
    try {
      final List<String> params = <String>[
        if (dni != null) 'dni=${Uri.encodeQueryComponent(dni)}',
        if (email != null) 'email=${Uri.encodeQueryComponent(email)}',
        if (telefono != null) 'telefono=${Uri.encodeQueryComponent(telefono)}',
      ];
      final String ruta = params.isEmpty
          ? '/api/clientes/buscar'
          : '/api/clientes/buscar?${params.join('&')}';
      final Object? json = await _api.get(ruta, token: token);
      return (json as List)
          .map((elemento) => Cliente.fromJson(elemento as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Cliente> obtenerPorId(int id, String token) async {
    try {
      final Object? json = await _api.get('/api/clientes/$id', token: token);
      return Cliente.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Cliente> crear(Cliente cliente, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/clientes',
        cuerpo: cliente.toJson(),
        token: token,
      );
      return Cliente.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  Future<Cliente> actualizar(int id, Cliente cliente, String token) async {
    try {
      final Object? json = await _api.put(
        '/api/clientes/$id',
        cuerpo: cliente.toJson(),
        token: token,
      );
      return Cliente.fromJson(json as Map<String, dynamic>);
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
        '/api/clientes/$id/imagen',
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

  Future<void> darDeBaja(int id, String token) async {
    try {
      await _api.delete('/api/clientes/$id', token: token);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
