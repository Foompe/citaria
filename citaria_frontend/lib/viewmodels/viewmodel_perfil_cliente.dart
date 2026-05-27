import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
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
  ViewModelPerfilCliente({
    required ViewModelAutenticacion autenticacion,
    required RepoClientes repoClientes,
  }) : _autenticacion = autenticacion,
       _repoClientes = repoClientes;

  final ViewModelAutenticacion _autenticacion;
  final RepoClientes _repoClientes;

  bool _cargando = false;
  bool _guardando = false;
  String? _error;
  DtoPerfilCliente? _datos;
  Cliente? _cliente;

  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;
  DtoPerfilCliente? get datos => _datos;

  Future<void> cargarPerfilDesdeSesion() async {
    _setCargando(true);
    _limpiarError();

    try {
      final Sesion sesion = _leerSesionCliente();
      final Cliente cliente = await _repoClientes.obtenerPorId(
        sesion.clienteId ?? 0,
        sesion.token,
      );
      _cliente = cliente;
      _datos = _crearDto(cliente, sesion.email);
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> actualizarDatos({
    required String nombre,
    required String apellidos,
    required String telefono,
  }) async {
    _setGuardando(true);
    _limpiarError();

    try {
      final Sesion sesion = _leerSesionCliente();
      final Cliente clienteActual =
          _cliente ??
          await _repoClientes.obtenerPorId(sesion.clienteId ?? 0, sesion.token);
      final Cliente clienteActualizado = Cliente(
        id: clienteActual.id,
        organizacionId: clienteActual.organizacionId,
        nombre: nombre.trim(),
        apellidos: _valorOpcional(apellidos),
        dni: clienteActual.dni,
        email: clienteActual.email ?? sesion.email,
        telefono: _valorOpcional(telefono),
        notas: clienteActual.notas,
        fotoUrl: clienteActual.fotoUrl,
        anonimizadoAt: clienteActual.anonimizadoAt,
        tieneUsuario: clienteActual.tieneUsuario,
      );
      final Cliente guardado = await _repoClientes.actualizar(
        sesion.clienteId ?? 0,
        clienteActualizado,
        sesion.token,
      );
      _cliente = guardado;
      _datos = _crearDto(guardado, sesion.email);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mensajeError(e));
      return false;
    } finally {
      _setGuardando(false);
    }
  }

  Future<bool> subirFoto({
    required List<int> bytes,
    required String nombreFichero,
  }) async {
    _setGuardando(true);
    _limpiarError();

    try {
      final Sesion sesion = _leerSesionCliente();
      await _repoClientes.subirFoto(
        sesion.clienteId ?? 0,
        bytes,
        nombreFichero,
        sesion.token,
      );
      final Cliente actualizado = await _repoClientes.obtenerPorId(
        sesion.clienteId ?? 0,
        sesion.token,
      );
      _cliente = actualizado;
      _datos = _crearDto(actualizado, sesion.email);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mensajeError(e));
      return false;
    } finally {
      _setGuardando(false);
    }
  }

  Future<bool> cerrarSesion() {
    return _autenticacion.cerrarSesion();
  }

  DtoPerfilCliente _crearDto(Cliente cliente, String fallbackEmail) {
    final String nombreCompleto = _crearNombreCompleto(
      cliente.nombre,
      cliente.apellidos,
      fallbackEmail,
    );
    return DtoPerfilCliente(
      nombre: cliente.nombre,
      apellidos: _texto(cliente.apellidos, 'No indicado'),
      email: _texto(cliente.email, fallbackEmail),
      telefono: _texto(cliente.telefono, 'No indicado'),
      fotoUrl: cliente.fotoUrl,
      iniciales: _crearIniciales(nombreCompleto),
      nombreCompleto: nombreCompleto,
    );
  }

  Sesion _leerSesionCliente() {
    final Sesion? sesion = _autenticacion.obtenerSesion();
    if (sesion == null || sesion.token.isEmpty) {
      throw StateError('Sesión no disponible.');
    }
    if (sesion.clienteId == null) {
      throw StateError('La sesión no tiene cliente asociado.');
    }
    return sesion;
  }

  String _crearNombreCompleto(
    String nombre,
    String? apellidos,
    String fallbackEmail,
  ) {
    final String nombreLimpio = nombre.trim();
    final String? apellidosLimpios = apellidos?.trim();
    if (nombreLimpio.isEmpty) {
      return fallbackEmail.split('@').first;
    }
    if (apellidosLimpios == null || apellidosLimpios.isEmpty) {
      return nombreLimpio;
    }
    return '$nombreLimpio $apellidosLimpios';
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) return 'C';
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) return primera;
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  String _texto(String? valor, String fallback) {
    final String? limpio = valor?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty || limpio == 'No indicado' ? null : limpio;
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

  void _setGuardando(bool valor) {
    _guardando = valor;
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
