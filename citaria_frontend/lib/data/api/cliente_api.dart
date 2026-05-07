import 'package:http/http.dart' as http;

/// Cliente HTTP base de Citaria.
///
/// Capa de acceso a red pura, sin lógica de negocio.
/// Inyectable por constructor para facilitar el testing.
class ClienteApi {
  ClienteApi(this._httpClient);

  final http.Client _httpClient;

  static const Duration _timeout = Duration(seconds: 10);

  static const Map<String, String> _cabecerasBase = {
    'Accept':       'application/json',
    'Content-Type': 'application/json',
  };

  /// URL base de la API.
  // TODO: configurar URL base — leer de variable de entorno o config
  String _baseUrl = '';

  /// Configura la URL base. Llamar antes del primer uso.
  void configurarBaseUrl(String url) => _baseUrl = url;

  /// GET [ruta] relativa a [_baseUrl].
  ///
  /// TODO: conectar API — añadir cabecera Authorization con JWT
  /// leído de flutter_secure_storage.
  Future<Map<String, dynamic>> get(String ruta) async {
    // TODO: conectar API
    throw UnimplementedError('GET $_baseUrl$ruta no implementado aún');
  }

  /// POST [ruta] relativa a [_baseUrl] con [cuerpo] serializado como JSON.
  ///
  /// TODO: conectar API — añadir cabecera Authorization con JWT
  /// leído de flutter_secure_storage.
  Future<Map<String, dynamic>> post(
    String ruta,
    Map<String, dynamic> cuerpo,
  ) async {
    // TODO: conectar API
    throw UnimplementedError('POST $_baseUrl$ruta no implementado aún');
  }

  /// Cierra el cliente HTTP subyacente.
  void dispose() => _httpClient.close();
}
