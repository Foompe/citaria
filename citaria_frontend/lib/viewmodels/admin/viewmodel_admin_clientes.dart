import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoClienteAdmin {
  const DtoClienteAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.iniciales,
    required this.tieneUsuario,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String dni;
  final String iniciales;
  final bool tieneUsuario;
}

class ViewModelAdminClientes extends ViewModelAdminBase {
  ViewModelAdminClientes({
    required RepoClientes repoClientes,
    required super.autenticacion,
  }) : _repoClientes = repoClientes;

  final RepoClientes _repoClientes;

  List<Cliente> _clientes = const <Cliente>[];
  String _busqueda = '';

  String get busqueda => _busqueda;

  List<DtoClienteAdmin> get clientes {
    final String filtro = _normalizar(_busqueda);
    return _clientes
        .where((cliente) => cliente.id != null)
        .where((cliente) => _coincideConBusqueda(cliente, filtro))
        .map(_crearDto)
        .toList(growable: false);
  }

  Future<void> cargarClientes() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Cliente> clientes = await _repoClientes.listarTodos(token);
      _clientes = clientes
          .where((cliente) => cliente.anonimizadoAt == null)
          .toList(growable: false)
        ..sort(_compararClientes);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarClientes();
  }

  void buscar(String valor) {
    if (_busqueda == valor) {
      return;
    }
    _busqueda = valor;
    notifyListeners();
  }

  DtoClienteAdmin _crearDto(Cliente cliente) {
    final String nombreCompleto = _crearNombreCompleto(cliente);
    return DtoClienteAdmin(
      id: cliente.id ?? 0,
      nombreCompleto: nombreCompleto,
      email: _textoConFallback(cliente.email, 'Sin email'),
      telefono: _textoConFallback(cliente.telefono, 'Sin teléfono'),
      dni: _textoConFallback(cliente.dni, 'Sin DNI'),
      iniciales: _crearIniciales(nombreCompleto),
      tieneUsuario: cliente.tieneUsuario,
    );
  }

  bool _coincideConBusqueda(Cliente cliente, String filtro) {
    if (filtro.isEmpty) {
      return true;
    }
    final List<String?> campos = <String?>[
      cliente.nombre,
      cliente.apellidos,
      cliente.email,
      cliente.telefono,
      cliente.dni,
    ];
    return campos.any((campo) => _normalizar(campo ?? '').contains(filtro));
  }

  int _compararClientes(Cliente a, Cliente b) {
    return _crearNombreCompleto(a).compareTo(_crearNombreCompleto(b));
  }

  String _crearNombreCompleto(Cliente cliente) {
    final String nombre = cliente.nombre.trim();
    final String? apellidos = _textoOpcional(cliente.apellidos);
    if (apellidos == null) {
      return nombre.isEmpty ? 'Cliente sin nombre' : nombre;
    }
    return '$nombre $apellidos';
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) {
      return 'C';
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
