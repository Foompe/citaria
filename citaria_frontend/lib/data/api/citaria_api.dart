import 'dart:convert';

import 'package:citaria_frontend/data/api/configuracion_api.dart';
import 'package:http/http.dart' as http;

class ExcepcionApi implements Exception {
  const ExcepcionApi(this.mensaje, this.statusCode);

  final String mensaje;
  final int statusCode;

  @override
  String toString() => mensaje;
}

class CitariaApi {
  CitariaApi(this._httpClient);

  final http.Client _httpClient;

  static const String _baseUrl = ConfiguracionApi.urlBase;
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _multipartTimeout = Duration(seconds: 30);

  Future<Object?> get(String ruta, {String? token}) {
    return _enviar(metodo: 'GET', ruta: ruta, token: token);
  }

  Future<Object?> post(
    String ruta, {
    Map<String, dynamic>? cuerpo,
    String? token,
  }) {
    return _enviar(metodo: 'POST', ruta: ruta, cuerpo: cuerpo, token: token);
  }

  Future<Object?> put(
    String ruta, {
    Map<String, dynamic>? cuerpo,
    String? token,
  }) {
    return _enviar(metodo: 'PUT', ruta: ruta, cuerpo: cuerpo, token: token);
  }

  Future<Object?> patch(
    String ruta, {
    Map<String, dynamic>? cuerpo,
    String? token,
  }) {
    return _enviar(metodo: 'PATCH', ruta: ruta, cuerpo: cuerpo, token: token);
  }

  Future<Object?> delete(String ruta, {String? token}) {
    return _enviar(metodo: 'DELETE', ruta: ruta, token: token);
  }

  Future<void> postMultipart(
    String ruta, {
    required List<int> bytes,
    required String nombreFichero,
    required String token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$ruta');
    final http.MultipartRequest peticion = http.MultipartRequest('POST', uri)
      ..headers.addAll(<String, String>{'Authorization': 'Bearer $token'})
      ..files.add(
        http.MultipartFile.fromBytes('archivo', bytes, filename: nombreFichero),
      );

    final http.StreamedResponse respuestaStream = await _httpClient
        .send(peticion)
        .timeout(_multipartTimeout);
    final http.Response respuesta = await http.Response.fromStream(
      respuestaStream,
    );
    _procesarRespuesta(respuesta);
  }

  Future<Object?> _enviar({
    required String metodo,
    required String ruta,
    Map<String, dynamic>? cuerpo,
    String? token,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$ruta');
    final Map<String, String> cabeceras = _crearCabeceras(
      token: token,
      incluirContenido: cuerpo != null,
    );
    final String? cuerpoJson = cuerpo == null ? null : jsonEncode(cuerpo);

    final http.Response respuesta = await _ejecutarPeticion(
      metodo: metodo,
      uri: uri,
      cabeceras: cabeceras,
      cuerpoJson: cuerpoJson,
    ).timeout(_timeout);

    return _procesarRespuesta(respuesta);
  }

  Future<http.Response> _ejecutarPeticion({
    required String metodo,
    required Uri uri,
    required Map<String, String> cabeceras,
    required String? cuerpoJson,
  }) {
    return switch (metodo) {
      'GET' => _httpClient.get(uri, headers: cabeceras),
      'POST' => _httpClient.post(uri, headers: cabeceras, body: cuerpoJson),
      'PUT' => _httpClient.put(uri, headers: cabeceras, body: cuerpoJson),
      'PATCH' => _httpClient.patch(uri, headers: cabeceras, body: cuerpoJson),
      'DELETE' => _httpClient.delete(uri, headers: cabeceras),
      _ => throw ArgumentError('Método HTTP no soportado: $metodo'),
    };
  }

  Map<String, String> _crearCabeceras({
    required String? token,
    required bool incluirContenido,
  }) {
    final Map<String, String> cabeceras = <String, String>{
      'Accept': 'application/json',
    };
    if (incluirContenido) {
      cabeceras['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      cabeceras['Authorization'] = 'Bearer $token';
    }
    return cabeceras;
  }

  Object? _procesarRespuesta(http.Response respuesta) {
    if (respuesta.statusCode == 204) {
      return null;
    }

    final Object? cuerpo = respuesta.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(respuesta.bodyBytes)) as Object?;

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    throw ExcepcionApi(_mensajeError(respuesta, cuerpo), respuesta.statusCode);
  }

  String _mensajeError(http.Response respuesta, Object? cuerpo) {
    if (cuerpo is Map<String, dynamic>) {
      final Object? mensaje = cuerpo['mensaje'];
      if (mensaje is String && mensaje.isNotEmpty) {
        return mensaje;
      }
    }
    final String motivo = respuesta.reasonPhrase ?? 'Error HTTP';
    return '$motivo (${respuesta.statusCode})';
  }
}
