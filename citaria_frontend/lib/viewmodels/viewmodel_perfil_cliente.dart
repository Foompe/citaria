import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoPerfilCliente {
  const DtoPerfilCliente({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.fotoUrl,
    required this.iniciales,
    required this.nombreCompleto,
  });

  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String? fotoUrl;
  final String iniciales;
  final String nombreCompleto;
}

class ViewModelPerfilCliente extends ChangeNotifier {
  ViewModelPerfilCliente({required ViewModelAutenticacion autenticacion})
    : _autenticacion = autenticacion;

  final ViewModelAutenticacion _autenticacion;

  bool _cargando = false;
  String? _error;
  DtoPerfilCliente? _datos;

  bool get cargando => _cargando;
  String? get error => _error;
  DtoPerfilCliente? get datos => _datos;

  Future<void> cargarPerfilDesdeSesion() async {
    _setCargando(true);
    _limpiarError();

    try {
      final DtoUsuarioSesion? usuario = _autenticacion.usuarioActual;
      if (usuario == null) {
        throw StateError('Sesión no disponible.');
      }
      _datos = DtoPerfilCliente(
        nombre: usuario.nombre,
        apellidos: _texto(usuario.apellidos, 'No indicado'),
        email: usuario.email,
        telefono: _texto(usuario.telefono, 'No indicado'),
        fotoUrl: usuario.fotoUrl,
        iniciales: usuario.iniciales,
        nombreCompleto: usuario.nombreCompleto,
      );
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cerrarSesion() {
    return _autenticacion.cerrarSesion();
  }

  String _texto(String? valor, String fallback) {
    final String? limpio = valor?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

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
