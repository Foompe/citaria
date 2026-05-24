import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestión local del PIN de administración.
///
/// El PIN se guarda en [FlutterSecureStorage] (cifrado por el OS).
/// El valor por defecto es "1234"; la flag [requiereCambio] indica si
/// el usuario aún no lo ha personalizado.
class ServicioPin {
  ServicioPin({required FlutterSecureStorage almacenamiento})
      : _almacenamiento = almacenamiento;

  final FlutterSecureStorage _almacenamiento;

  static const String _clavePin      = 'citaria_pin';
  static const String _claveCambiado = 'citaria_pin_cambiado';
  static const String _pinDefecto    = '1234';

  /// Escribe el PIN por defecto si no existe ninguno almacenado.
  /// Debe llamarse una vez al arranque de la app.
  Future<void> inicializar() async {
    final String? pin = await _almacenamiento.read(key: _clavePin);
    if (pin == null) {
      await _almacenamiento.write(key: _clavePin,      value: _pinDefecto);
      await _almacenamiento.write(key: _claveCambiado, value: 'false');
    }
  }

  /// Devuelve [true] si [pin] coincide con el almacenado.
  Future<bool> verificar(String pin) async {
    final String? almacenado = await _almacenamiento.read(key: _clavePin);
    return almacenado == pin;
  }

  /// Guarda [nuevo] como PIN y marca que ya fue personalizado.
  Future<void> cambiar(String nuevo) async {
    await _almacenamiento.write(key: _clavePin,      value: nuevo);
    await _almacenamiento.write(key: _claveCambiado, value: 'true');
  }

  /// Devuelve [true] si el usuario nunca ha cambiado el PIN por defecto.
  Future<bool> requiereCambio() async {
    final String? cambiado = await _almacenamiento.read(key: _claveCambiado);
    return cambiado != 'true';
  }
}
