import 'package:citaria_frontend/data/enums/rol_usuario.dart';
import 'package:citaria_frontend/data/models/configuracion_visual.dart';
import 'package:citaria_frontend/data/models/organizacion.dart';
import 'package:citaria_frontend/data/models/usuario.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_usuarios.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoAjustesEmpresaAdmin {
  const DtoAjustesEmpresaAdmin({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.cif,
    required this.pais,
  });

  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String cif;
  final String pais;
}

@immutable
class DtoAjustesCuentaAdmin {
  const DtoAjustesCuentaAdmin({
    required this.email,
    required this.rol,
    required this.estado,
    required this.emailVerificado,
  });

  final String email;
  final String rol;
  final String estado;
  final String emailVerificado;
}

@immutable
class DtoAjustesVisualAdmin {
  const DtoAjustesVisualAdmin({
    required this.logoUrl,
    required this.colorPrimario,
    required this.colorSecundario,
    required this.tipografia,
    required this.version,
  });

  final String logoUrl;
  final String colorPrimario;
  final String colorSecundario;
  final String tipografia;
  final String version;
}

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
        _repoOrganizaciones.obtenerConfiguracion(organizacionId),
        _repoUsuarios.obtenerActual(token),
      ]);

      _empresa = _crearEmpresa(resultados[0] as Organizacion);
      _visual = _crearVisual(resultados[1] as ConfiguracionVisual);
      _cuenta = _crearCuenta(resultados[2] as Usuario);
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

  DtoAjustesEmpresaAdmin _crearEmpresa(Organizacion organizacion) {
    return DtoAjustesEmpresaAdmin(
      nombre: _textoConFallback(organizacion.nombre, 'Sin nombre'),
      direccion: _crearDireccion(organizacion),
      telefono: _textoConFallback(organizacion.telefono, 'Sin teléfono'),
      email: _textoConFallback(organizacion.email, 'Sin email'),
      cif: _textoConFallback(organizacion.cif, 'Sin CIF'),
      pais: _textoConFallback(organizacion.pais, 'Sin país'),
    );
  }

  DtoAjustesCuentaAdmin _crearCuenta(Usuario usuario) {
    return DtoAjustesCuentaAdmin(
      email: _textoConFallback(usuario.email, 'Sin email'),
      rol: _textoRol(usuario.rol),
      estado: (usuario.activo ?? true) ? 'Activa' : 'Inactiva',
      emailVerificado: (usuario.emailVerificado ?? false)
          ? 'Verificado'
          : 'Sin verificar',
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
}
