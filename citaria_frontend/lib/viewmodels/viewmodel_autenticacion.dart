import 'package:flutter/foundation.dart';

/// Roles posibles de un usuario en Citaria.
enum RolUsuario { cliente, admin }

/// Datos básicos del usuario autenticado.
@immutable
class DatosUsuario {
  const DatosUsuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String email;
  final RolUsuario rol;
}

/// ViewModel de autenticación.
///
/// Gestiona el estado de sesión: cargando, error, usuario actual.
/// Los métodos de negocio están preparados para conectar con la API.
class ViewModelAutenticacion extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  DatosUsuario? _usuarioActual;

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get cargando => _cargando;
  String? get error => _error;
  DatosUsuario? get usuarioActual => _usuarioActual;

  /// `true` si hay un usuario activo en sesión.
  bool get estaAutenticado => _usuarioActual != null;

  /// `true` si el usuario actual tiene rol de administrador.
  bool get esAdmin =>
      _usuarioActual != null && _usuarioActual!.rol == RolUsuario.admin;

  // ── Métodos de negocio ─────────────────────────────────────────────────────

  /// Inicia sesión con [email] y [password].
  ///
  /// TODO: conectar API — POST /auth/login
  /// Almacenar JWT resultante en flutter_secure_storage.
  Future<void> iniciarSesion(String email, String password) async {
    _setCargando(true);
    _limpiarError();
    try {
      // TODO: conectar API
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCargando(false);
    }
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// TODO: conectar API — POST /auth/logout
  /// Limpiar JWT de flutter_secure_storage.
  Future<void> cerrarSesion() async {
    _setCargando(true);
    _limpiarError();
    try {
      // TODO: conectar API
      _usuarioActual = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCargando(false);
    }
  }

  /// Comprueba si existe una sesión activa al arrancar la app.
  ///
  /// TODO: conectar API — leer JWT de flutter_secure_storage
  /// y validar con GET /auth/me.
  Future<void> verificarSesion() async {
    _setCargando(true);
    _limpiarError();
    try {
      // TODO: conectar API
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCargando(false);
    }
  }

  // ── Helpers privados ───────────────────────────────────────────────────────

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }

  void _setError(String mensaje) {
    _error = mensaje;
    notifyListeners();
  }

  void _limpiarError() {
    _error = null;
  }
}
