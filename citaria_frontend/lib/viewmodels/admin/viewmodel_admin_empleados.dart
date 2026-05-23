import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoAdmin {
  const DtoEmpleadoAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.iniciales,
    required this.activo,
    required this.estado,
    required this.resumen,
    required this.fotoUrl,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String iniciales;
  final bool activo;
  final String estado;
  final String resumen;
  final String? fotoUrl;
}

class ViewModelAdminEmpleados extends ViewModelAdminBase {
  ViewModelAdminEmpleados({
    required RepoEmpleados repoEmpleados,
    required super.autenticacion,
  }) : _repoEmpleados = repoEmpleados;

  final RepoEmpleados _repoEmpleados;

  List<Empleado> _empleados = const <Empleado>[];
  String _busqueda = '';

  String get busqueda => _busqueda;

  List<DtoEmpleadoAdmin> get empleados {
    final String filtro = _normalizar(_busqueda);
    return _empleados
        .where((empleado) => empleado.id != null)
        .where((empleado) => _coincideConBusqueda(empleado, filtro))
        .map(_crearDto)
        .toList(growable: false);
  }

  Future<void> cargarEmpleados() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Empleado> empleados = await _repoEmpleados.listarTodos(token);
      _empleados =
          empleados
              .where((empleado) => empleado.anonimizadoAt == null)
              .toList(growable: false)
            ..sort(_compararEmpleados);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarEmpleados();
  }

  void buscar(String valor) {
    if (_busqueda == valor) {
      return;
    }
    _busqueda = valor;
    notifyListeners();
  }

  DtoEmpleadoAdmin _crearDto(Empleado empleado) {
    final String nombreCompleto = _crearNombreCompleto(empleado);
    final bool activo = empleado.activo ?? true;
    return DtoEmpleadoAdmin(
      id: empleado.id ?? 0,
      nombreCompleto: nombreCompleto,
      email: _textoConFallback(empleado.email, 'Sin email'),
      telefono: _textoConFallback(empleado.telefono, 'Sin teléfono'),
      iniciales: _crearIniciales(nombreCompleto),
      activo: activo,
      estado: activo ? 'Activo' : 'Inactivo',
      resumen: _crearResumen(empleado),
      fotoUrl: _textoOpcional(empleado.fotoUrl),
    );
  }

  bool _coincideConBusqueda(Empleado empleado, String filtro) {
    if (filtro.isEmpty) {
      return true;
    }
    final List<String?> campos = <String?>[
      empleado.nombre,
      empleado.apellidos,
      empleado.email,
      empleado.telefono,
    ];
    return campos.any((campo) => _normalizar(campo ?? '').contains(filtro));
  }

  int _compararEmpleados(Empleado a, Empleado b) {
    return _crearNombreCompleto(a).compareTo(_crearNombreCompleto(b));
  }

  String _crearNombreCompleto(Empleado empleado) {
    final String nombre = empleado.nombre.trim();
    final String? apellidos = _textoOpcional(empleado.apellidos);
    if (apellidos == null) {
      return nombre.isEmpty ? 'Empleado sin nombre' : nombre;
    }
    return '$nombre $apellidos';
  }

  String _crearResumen(Empleado empleado) {
    final String email = _textoConFallback(empleado.email, 'Sin email');
    final String telefono = _textoConFallback(
      empleado.telefono,
      'Sin teléfono',
    );
    return '$email · $telefono';
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) {
      return 'E';
    }
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) {
      return primera;
    }
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String _normalizar(String texto) {
    return texto.trim().toLowerCase();
  }
}
