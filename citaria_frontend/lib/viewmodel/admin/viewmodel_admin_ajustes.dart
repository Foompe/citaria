import 'package:citaria_frontend/data/enums/rol_usuario.dart';
import 'package:citaria_frontend/data/models/configuracion_visual.dart';
import 'package:citaria_frontend/data/models/organizacion.dart';
import 'package:citaria_frontend/data/models/usuario.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_usuarios.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_cuenta_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_empresa_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_visual_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_base.dart';

/// Gestiona los ajustes del panel admin: datos de la empresa, de la cuenta
/// y la apariencia visual.
class ViewModelAdminAjustes extends ViewModelAdminBase {
  ViewModelAdminAjustes({
    required RepoOrganizaciones repoOrganizaciones,
    required RepoUsuarios repoUsuarios,
    required super.autenticacion,
  }) : _repoOrganizaciones = repoOrganizaciones,
       _repoUsuarios = repoUsuarios;

  final RepoOrganizaciones _repoOrganizaciones;
  final RepoUsuarios _repoUsuarios;

  DtoAjustesEmpresaAdmin? _empresa;
  DtoAjustesCuentaAdmin? _cuenta;
  DtoAjustesVisualAdmin? _visual;
  Organizacion? _organizacionOriginal;

  DtoAjustesEmpresaAdmin? get empresa => _empresa;
  DtoAjustesCuentaAdmin? get cuenta => _cuenta;
  DtoAjustesVisualAdmin? get visual => _visual;

  Future<void> cargarAjustes() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final int organizacionId = leerOrganizacionIdObligatoria();

      final resultados = await Future.wait<Object>(<Future<Object>>[
        _repoOrganizaciones.obtenerPorId(organizacionId, token),
        _repoUsuarios.obtenerActual(token),
      ]);

      _organizacionOriginal = resultados[0] as Organizacion;
      _empresa = _crearEmpresa(_organizacionOriginal!);
      _cuenta = _crearCuenta(resultados[1] as Usuario);

      try {
        final ConfiguracionVisual visual =
            await _repoOrganizaciones.obtenerConfiguracion(organizacionId);
        _visual = _crearVisual(visual);
      } catch (_) {
        _visual = null;
      }

      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarAjustes();
  }

  Future<String?> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    try {
      final String token = leerTokenObligatorio();
      await _repoUsuarios.cambiarPassword(passwordActual, passwordNueva, token);
      return null;
    } catch (e) {
      return mensajeError(e);
    }
  }

  Future<bool> actualizarEmpresa({
    required String email,
    required String telefono,
    required String cif,
    required String calle,
    required String codigoPostal,
    required String ciudad,
    required String pais,
  }) async {
    final Organizacion? original = _organizacionOriginal;
    final int? id = original?.id;
    if (original == null || id == null) {
      registrarError('No hay datos de empresa disponibles.');
      return false;
    }

    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Organizacion actualizada = await _repoOrganizaciones.actualizar(
        id,
        Organizacion(
          id: id,
          nombre: original.nombre,
          email: email.trim(),
          telefono: _valorOpcional(telefono),
          cif: _valorOpcional(cif),
          calle: _valorOpcional(calle),
          codigoPostal: _valorOpcional(codigoPostal),
          ciudad: _valorOpcional(ciudad),
          pais: pais.trim().toUpperCase(),
          tokenRegistro: original.tokenRegistro,
        ),
        token,
      );
      _organizacionOriginal = actualizada;
      _empresa = _crearEmpresa(actualizada);
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  DtoAjustesEmpresaAdmin _crearEmpresa(Organizacion organizacion) {
    return DtoAjustesEmpresaAdmin(
      nombre: _textoConFallback(organizacion.nombre, 'Sin nombre'),
      direccion: _crearDireccion(organizacion),
      telefono: _textoConFallback(organizacion.telefono, 'Sin teléfono'),
      email: _textoConFallback(organizacion.email, 'Sin email'),
      cif: _textoConFallback(organizacion.cif, 'Sin CIF'),
      calle: organizacion.calle ?? '',
      codigoPostal: organizacion.codigoPostal ?? '',
      ciudad: organizacion.ciudad ?? '',
      pais: _textoConFallback(organizacion.pais, 'Sin país'),
    );
  }

  DtoAjustesCuentaAdmin _crearCuenta(Usuario usuario) {
    return DtoAjustesCuentaAdmin(
      email: _textoConFallback(usuario.email, 'Sin email'),
      rol: _textoRol(usuario.rol),
      estado: (usuario.activo ?? true) ? 'Activa' : 'Inactiva',
    );
  }

  DtoAjustesVisualAdmin _crearVisual(ConfiguracionVisual configuracion) {
    return DtoAjustesVisualAdmin(
      logoUrl: _textoConFallback(configuracion.logoUrl, 'Sin logo'),
      colorPrimario: _textoConFallback(
        configuracion.colorPrimario,
        'Color por defecto',
      ),
      colorSecundario: _textoConFallback(
        configuracion.colorSecundario,
        'Color por defecto',
      ),
      tipografia: _textoConFallback(configuracion.tipografia, 'Por defecto'),
      version: configuracion.version?.toString() ?? 'Sin versión',
    );
  }

  String _crearDireccion(Organizacion organizacion) {
    final List<String> partes = <String>[
      if (_textoOpcional(organizacion.calle) != null) organizacion.calle!,
      if (_textoOpcional(organizacion.codigoPostal) != null)
        organizacion.codigoPostal!,
      if (_textoOpcional(organizacion.ciudad) != null) organizacion.ciudad!,
    ];
    return partes.isEmpty ? 'Sin dirección' : partes.join(', ');
  }

  String _textoRol(RolUsuario rol) {
    return switch (rol) {
      RolUsuario.admin => 'Administrador',
      RolUsuario.empleado => 'Empleado',
      RolUsuario.cliente => 'Cliente',
    };
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }
}
