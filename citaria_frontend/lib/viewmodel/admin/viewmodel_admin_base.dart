import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:flutter/foundation.dart';

/// Base común de los viewmodels de administración: estado de carga, gestión
/// de errores, acceso a la sesión y notificación segura tras el dispose.
abstract class ViewModelAdminBase extends ChangeNotifier {
  ViewModelAdminBase({required ViewModelAutenticacion autenticacion})
    : _autenticacion = autenticacion;

  final ViewModelAutenticacion _autenticacion;

  bool _cargando = false;
  String? _error;
  bool _disposed = false;

  bool get cargando => _cargando;
  String? get error => _error;
  Sesion? get sesion => _autenticacion.obtenerSesion();

  Sesion leerSesionObligatoria() {
    final Sesion? sesionActual = _autenticacion.obtenerSesion();
    if (sesionActual == null) {
      throw StateError('Sesión no disponible.');
    }
    return sesionActual;
  }

  String leerTokenObligatorio() {
    return leerSesionObligatoria().token;
  }

  int leerOrganizacionIdObligatoria() {
    return leerSesionObligatoria().organizacionId;
  }

  void iniciarCarga() {
    _cargando = true;
    _error = null;
    notifyListeners();
  }

  void finalizarCarga() {
    _cargando = false;
    notifyListeners();
  }

  void registrarError(Object error) {
    _error = mensajeError(error);
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
  }

  String mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Evita notificar tras el dispose: si la pantalla se cierra mientras hay
  /// una petición en vuelo, su callback ya no toca un notifier destruido.
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }
}
