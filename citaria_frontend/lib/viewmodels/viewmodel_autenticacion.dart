import 'package:citaria_frontend/data/enums/rol_usuario.dart';
import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/models/organizacion_publica.dart';
import 'package:citaria_frontend/data/models/peticion_login.dart';
import 'package:citaria_frontend/data/models/registro.dart';
import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/data/models/usuario.dart';
import 'package:citaria_frontend/data/repositories/repo_auth.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RolUsuarioPresentacion { admin, empleado, cliente }

enum DestinoAutenticacion { seleccionEmpresa, login, homeCliente, homeAdmin }

@immutable
class DtoUsuarioSesion {
  const DtoUsuarioSesion({
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.fotoUrl,
    required this.iniciales,
    required this.nombreCompleto,
  });

  final String email;
  final RolUsuarioPresentacion rol;
  final String nombre;
  final String? apellidos;
  final String? telefono;
  final String? fotoUrl;
  final String iniciales;
  final String nombreCompleto;
}

@immutable
class DtoEmpresaActiva {
  const DtoEmpresaActiva({
    required this.id,
    required this.nombre,
    required this.logoUrl,
    required this.tokenRegistro,
  });

  final int id;
  final String nombre;
  final String? logoUrl;
  final String tokenRegistro;
}

@immutable
class DtoEmpresaSeleccionable {
  const DtoEmpresaSeleccionable({
    required this.id,
    required this.nombre,
    required this.logoUrl,
    required this.tokenRegistro,
  });

  final int id;
  final String nombre;
  final String? logoUrl;
  final String tokenRegistro;
}

class ViewModelAutenticacion extends ChangeNotifier {
  ViewModelAutenticacion({
    required RepoAuth repoAuth,
    required RepoOrganizaciones repoOrganizaciones,
    required RepoClientes repoClientes,
    required RepoEmpleados repoEmpleados,
    required FlutterSecureStorage almacenamientoSeguro,
    required SharedPreferences preferencias,
  }) : _repoAuth = repoAuth,
       _repoOrganizaciones = repoOrganizaciones,
       _repoClientes = repoClientes,
       _repoEmpleados = repoEmpleados,
       _almacenamientoSeguro = almacenamientoSeguro,
       _preferencias = preferencias {
    _empresaActiva = _leerEmpresaActiva();
  }

  static const String _claveToken = 'citaria.jwt';
  static const String _claveOrganizacionId = 'citaria.organizacionId';
  static const String _claveTokenRegistro = 'citaria.tokenRegistro';
  static const String _claveNombreEmpresa = 'citaria.nombreEmpresa';
  static const String _claveLogoEmpresa = 'citaria.logoEmpresa';

  final RepoAuth _repoAuth;
  final RepoOrganizaciones _repoOrganizaciones;
  final RepoClientes _repoClientes;
  final RepoEmpleados _repoEmpleados;
  final FlutterSecureStorage _almacenamientoSeguro;
  final SharedPreferences _preferencias;

  bool _cargando = false;
  String? _error;
  DtoUsuarioSesion? _usuarioActual;
  DtoEmpresaActiva? _empresaActiva;
  List<DtoEmpresaSeleccionable> _empresas = const <DtoEmpresaSeleccionable>[];
  Sesion? _sesion;

  bool get cargando => _cargando;
  String? get error => _error;
  DtoUsuarioSesion? get usuarioActual => _usuarioActual;
  DtoEmpresaActiva? get empresaActiva => _empresaActiva;
  List<DtoEmpresaSeleccionable> get empresas => _empresas;
  bool get estaAutenticado => _usuarioActual != null;
  bool get esAdmin => _usuarioActual?.rol == RolUsuarioPresentacion.admin;
  bool get esCliente => _usuarioActual?.rol == RolUsuarioPresentacion.cliente;
  bool get hayEmpresaSeleccionada => _empresaActiva != null;

  Future<DestinoAutenticacion> verificarSesion({ViewModelTema? tema}) async {
    _setCargando(true);
    _limpiarError();

    try {
      final String? token = await _almacenamientoSeguro.read(key: _claveToken);
      if (token == null || token.isEmpty) {
        _limpiarSesionEnMemoria();
        return _destinoSinSesion();
      }

      final Usuario usuario = await _obtenerUsuarioConToken(token);
      await _reconstruirSesion(token: token, usuario: usuario);

      final int? organizacionId = usuario.organizacionId;
      if (organizacionId != null) {
        await _guardarEmpresaDesdeUsuarioSiEsPosible(organizacionId);
        await _comprobarTemaSiEsPosible(tema, organizacionId);
      }

      return _destinoPorRol(usuario.rol);
    } on ExcepcionApi catch (e) {
      if (!_sesionDebeExpirar(e)) {
        _setError(e.mensaje);
        return _destinoConSesionActual();
      }
      await _almacenamientoSeguro.delete(key: _claveToken);
      _limpiarSesionEnMemoria();
      final int? orgId = _preferencias.getInt(_claveOrganizacionId);
      if (orgId != null) {
        await _comprobarTemaSiEsPosible(tema, orgId);
      }
      return _destinoSinSesion();
    } catch (e) {
      _setError(_mensajeError(e));
      if (_sesion != null) {
        return _destinoConSesionActual();
      }
      return _destinoSinSesion();
    } finally {
      _setCargando(false);
    }
  }

  Future<DestinoAutenticacion?> iniciarSesion({
    required String email,
    required String password,
    required ViewModelTema tema,
  }) async {
    _setCargando(true);
    _limpiarError();

    try {
      final int? organizacionId = _preferencias.getInt(_claveOrganizacionId);
      if (organizacionId == null) {
        _setError('Selecciona una empresa antes de iniciar sesión.');
        return null;
      }

      final respuesta = await _repoAuth.login(
        PeticionLogin(
          email: email,
          password: password,
          organizacionId: organizacionId,
        ),
      );

      await _almacenamientoSeguro.write(
        key: _claveToken,
        value: respuesta.token,
      );

      final Usuario usuario = await _repoAuth.obtenerUsuarioActual(
        respuesta.token,
      );
      await _reconstruirSesion(token: respuesta.token, usuario: usuario);
      await _guardarEmpresaDesdeUsuario(usuario.organizacionId);

      final int? idTema = usuario.organizacionId;
      if (idTema != null) {
        await tema.cargarTemaEmpresa(idTema);
      }

      return _destinoPorRol(usuario.rol);
    } catch (e) {
      _setError(_mensajeError(e));
      return null;
    } finally {
      _setCargando(false);
    }
  }

  Future<DestinoAutenticacion?> registrar({
    required String nombre,
    required String? apellidos,
    required String email,
    required String? telefono,
    required String password,
    required ViewModelTema tema,
  }) async {
    _setCargando(true);
    _limpiarError();

    try {
      final String? tokenRegistro = _preferencias.getString(
        _claveTokenRegistro,
      );
      if (tokenRegistro == null || tokenRegistro.isEmpty) {
        _setError('Selecciona una empresa antes de registrarte.');
        return null;
      }

      final respuesta = await _repoAuth.registro(
        Registro(
          tokenRegistro: tokenRegistro,
          email: email,
          password: password,
          nombre: nombre,
          apellidos: apellidos,
          telefono: telefono,
        ),
      );

      await _almacenamientoSeguro.write(
        key: _claveToken,
        value: respuesta.token,
      );

      final Usuario usuario = await _repoAuth.obtenerUsuarioActual(
        respuesta.token,
      );
      await _reconstruirSesion(token: respuesta.token, usuario: usuario);
      await _guardarEmpresaDesdeUsuario(usuario.organizacionId);

      final int? organizacionId = usuario.organizacionId;
      if (organizacionId != null) {
        await tema.cargarTemaEmpresa(organizacionId);
      }

      return _destinoPorRol(usuario.rol);
    } catch (e) {
      _setError(_mensajeError(e));
      return null;
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cargarEmpresasPublicas() async {
    _setCargando(true);
    _limpiarError();

    try {
      final List<OrganizacionPublica> organizaciones = await _repoOrganizaciones
          .listarPublicas();
      _empresas = organizaciones
          .map(_crearEmpresaSeleccionable)
          .whereType<DtoEmpresaSeleccionable>()
          .toList(growable: false);
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> seleccionarEmpresa(
    DtoEmpresaSeleccionable empresa, {
    required ViewModelTema tema,
  }) async {
    _setCargando(true);
    _limpiarError();

    try {
      await _guardarEmpresa(
        id: empresa.id,
        nombre: empresa.nombre,
        logoUrl: empresa.logoUrl,
        tokenRegistro: empresa.tokenRegistro,
      );
      await tema.cargarTemaEmpresa(empresa.id);
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> cerrarSesion() async {
    _setCargando(true);
    _limpiarError();

    try {
      await _almacenamientoSeguro.delete(key: _claveToken);
      String? token = await _almacenamientoSeguro.read(key: _claveToken);
      if (token != null && token.isNotEmpty) {
        await _almacenamientoSeguro.write(key: _claveToken, value: '');
        token = await _almacenamientoSeguro.read(key: _claveToken);
      }
      if (token != null && token.isNotEmpty) {
        throw StateError('No se ha podido cerrar la sesión.');
      }
      _limpiarSesionEnMemoria();
      return true;
    } catch (e) {
      _setError(_mensajeError(e));
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<String?> leerToken() {
    return _almacenamientoSeguro.read(key: _claveToken);
  }

  Sesion? obtenerSesion() => _sesion;

  Future<Usuario> _obtenerUsuarioConToken(String token) {
    return _repoAuth.obtenerUsuarioActual(token);
  }

  bool _sesionDebeExpirar(ExcepcionApi error) {
    return error.statusCode == 401 || error.statusCode == 403;
  }

  DestinoAutenticacion _destinoConSesionActual() {
    final RolUsuario? rol = _sesion?.rol;
    return rol == null ? _destinoSinSesion() : _destinoPorRol(rol);
  }

  Future<void> _reconstruirSesion({
    required String token,
    required Usuario usuario,
  }) async {
    final int? organizacionId = usuario.organizacionId;
    if (organizacionId == null) {
      throw StateError('El usuario autenticado no tiene organización.');
    }

    _sesion = Sesion(
      token: token,
      email: usuario.email,
      rol: usuario.rol,
      organizacionId: organizacionId,
      clienteId: usuario.clienteId,
      empleadoId: usuario.empleadoId,
    );
    _usuarioActual = await _crearDtoUsuario(token: token, usuario: usuario);
    notifyListeners();
  }

  Future<DtoUsuarioSesion> _crearDtoUsuario({
    required String token,
    required Usuario usuario,
  }) async {
    return switch (usuario.rol) {
      RolUsuario.cliente => _crearDtoCliente(token: token, usuario: usuario),
      RolUsuario.empleado => _crearDtoEmpleado(token: token, usuario: usuario),
      RolUsuario.admin => _crearDtoAdmin(usuario),
    };
  }

  Future<DtoUsuarioSesion> _crearDtoCliente({
    required String token,
    required Usuario usuario,
  }) async {
    final int? clienteId = usuario.clienteId;
    if (clienteId == null) {
      return _crearDtoAdmin(usuario);
    }

    late final Cliente cliente;
    try {
      cliente = await _repoClientes.obtenerPorId(clienteId, token);
    } catch (_) {
      return _crearDtoAdmin(usuario);
    }
    final String nombreCompleto = _crearNombreCompleto(
      cliente.nombre,
      cliente.apellidos,
      usuario.email,
    );

    return DtoUsuarioSesion(
      email: usuario.email,
      rol: RolUsuarioPresentacion.cliente,
      nombre: cliente.nombre,
      apellidos: cliente.apellidos,
      telefono: cliente.telefono,
      fotoUrl: cliente.fotoUrl,
      iniciales: _crearIniciales(nombreCompleto),
      nombreCompleto: nombreCompleto,
    );
  }

  Future<DtoUsuarioSesion> _crearDtoEmpleado({
    required String token,
    required Usuario usuario,
  }) async {
    final int? empleadoId = usuario.empleadoId;
    if (empleadoId == null) {
      return _crearDtoAdmin(usuario);
    }

    late final Empleado empleado;
    try {
      empleado = await _repoEmpleados.obtenerPorId(empleadoId, token);
    } catch (_) {
      return _crearDtoAdmin(usuario);
    }
    final String nombreCompleto = _crearNombreCompleto(
      empleado.nombre,
      empleado.apellidos,
      usuario.email,
    );

    return DtoUsuarioSesion(
      email: usuario.email,
      rol: RolUsuarioPresentacion.empleado,
      nombre: empleado.nombre,
      apellidos: empleado.apellidos,
      telefono: empleado.telefono,
      fotoUrl: empleado.fotoUrl,
      iniciales: _crearIniciales(nombreCompleto),
      nombreCompleto: nombreCompleto,
    );
  }

  DtoUsuarioSesion _crearDtoAdmin(Usuario usuario) {
    final String nombre = _nombreDesdeEmail(usuario.email);

    return DtoUsuarioSesion(
      email: usuario.email,
      rol: _rolPresentacion(usuario.rol),
      nombre: nombre,
      apellidos: null,
      telefono: null,
      fotoUrl: null,
      iniciales: _crearIniciales(nombre),
      nombreCompleto: nombre,
    );
  }

  Future<void> _guardarEmpresaDesdeUsuario(int? organizacionId) async {
    if (organizacionId == null) return;

    final DtoEmpresaActiva? empresaActual = _empresaActiva;
    if (empresaActual != null && empresaActual.id == organizacionId) {
      await _guardarEmpresa(
        id: empresaActual.id,
        nombre: empresaActual.nombre,
        logoUrl: empresaActual.logoUrl,
        tokenRegistro: empresaActual.tokenRegistro,
      );
      return;
    }

    final List<OrganizacionPublica> organizaciones = await _repoOrganizaciones
        .listarPublicas();
    for (final OrganizacionPublica organizacion in organizaciones) {
      if (organizacion.id == organizacionId) {
        await _guardarEmpresa(
          id: organizacionId,
          nombre: organizacion.nombre ?? 'Empresa',
          logoUrl: organizacion.logoUrl,
          tokenRegistro: organizacion.tokenRegistro ?? '',
        );
        return;
      }
    }

    await _preferencias.setInt(_claveOrganizacionId, organizacionId);
  }

  Future<void> _guardarEmpresaDesdeUsuarioSiEsPosible(
    int organizacionId,
  ) async {
    try {
      await _guardarEmpresaDesdeUsuario(organizacionId);
    } catch (_) {
      await _preferencias.setInt(_claveOrganizacionId, organizacionId);
    }
  }

  Future<void> _comprobarTemaSiEsPosible(
    ViewModelTema? tema,
    int organizacionId,
  ) async {
    try {
      await tema?.comprobarActualizacion(organizacionId);
    } catch (_) {
      // La sesión no debe caer por un fallo al refrescar el tema.
    }
  }

  Future<void> _guardarEmpresa({
    required int id,
    required String nombre,
    required String? logoUrl,
    required String tokenRegistro,
  }) async {
    await _preferencias.setInt(_claveOrganizacionId, id);
    await _preferencias.setString(_claveNombreEmpresa, nombre);
    await _preferencias.setString(_claveTokenRegistro, tokenRegistro);
    if (logoUrl == null || logoUrl.isEmpty) {
      await _preferencias.remove(_claveLogoEmpresa);
    } else {
      await _preferencias.setString(_claveLogoEmpresa, logoUrl);
    }

    _empresaActiva = DtoEmpresaActiva(
      id: id,
      nombre: nombre,
      logoUrl: logoUrl,
      tokenRegistro: tokenRegistro,
    );
    notifyListeners();
  }

  DtoEmpresaActiva? _leerEmpresaActiva() {
    final int? id = _preferencias.getInt(_claveOrganizacionId);
    final String? nombre = _preferencias.getString(_claveNombreEmpresa);
    final String? tokenRegistro = _preferencias.getString(_claveTokenRegistro);
    if (id == null || nombre == null || tokenRegistro == null) {
      return null;
    }

    return DtoEmpresaActiva(
      id: id,
      nombre: nombre,
      logoUrl: _preferencias.getString(_claveLogoEmpresa),
      tokenRegistro: tokenRegistro,
    );
  }

  DtoEmpresaSeleccionable? _crearEmpresaSeleccionable(
    OrganizacionPublica organizacion,
  ) {
    final int? id = organizacion.id;
    final String? nombre = organizacion.nombre;
    final String? tokenRegistro = organizacion.tokenRegistro;
    if (id == null ||
        nombre == null ||
        nombre.isEmpty ||
        tokenRegistro == null ||
        tokenRegistro.isEmpty) {
      return null;
    }

    return DtoEmpresaSeleccionable(
      id: id,
      nombre: nombre,
      logoUrl: organizacion.logoUrl,
      tokenRegistro: tokenRegistro,
    );
  }

  DestinoAutenticacion _destinoSinSesion() {
    return _preferencias.getInt(_claveOrganizacionId) == null
        ? DestinoAutenticacion.seleccionEmpresa
        : DestinoAutenticacion.login;
  }

  DestinoAutenticacion _destinoPorRol(RolUsuario rol) {
    return switch (rol) {
      RolUsuario.admin || RolUsuario.empleado => DestinoAutenticacion.homeAdmin,
      RolUsuario.cliente => DestinoAutenticacion.homeCliente,
    };
  }

  RolUsuarioPresentacion _rolPresentacion(RolUsuario rol) {
    return switch (rol) {
      RolUsuario.admin => RolUsuarioPresentacion.admin,
      RolUsuario.empleado => RolUsuarioPresentacion.empleado,
      RolUsuario.cliente => RolUsuarioPresentacion.cliente,
    };
  }

  String _crearNombreCompleto(
    String nombre,
    String? apellidos,
    String fallbackEmail,
  ) {
    final String nombreLimpio = nombre.trim();
    final String? apellidosLimpios = apellidos?.trim();
    if (nombreLimpio.isEmpty) {
      return _nombreDesdeEmail(fallbackEmail);
    }
    if (apellidosLimpios == null || apellidosLimpios.isEmpty) {
      return nombreLimpio;
    }
    return '$nombreLimpio $apellidosLimpios';
  }

  String _nombreDesdeEmail(String email) {
    final String local = email.split('@').first.trim();
    return local.isEmpty ? 'Usuario' : local;
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) {
      return 'U';
    }
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) {
      return primera;
    }
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

  void _limpiarSesionEnMemoria() {
    _sesion = null;
    _usuarioActual = null;
    notifyListeners();
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
