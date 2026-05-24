import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class DtoClienteAdmin {
  const DtoClienteAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.iniciales,
    required this.fotoUrl,
    required this.tieneUsuario,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String dni;
  final String iniciales;
  final String? fotoUrl;
  final bool tieneUsuario;
}

@immutable
class DtoDetalleClienteAdmin {
  const DtoDetalleClienteAdmin({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.nombreCompleto,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.notas,
    required this.iniciales,
    required this.fotoUrl,
    required this.tieneUsuario,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String nombreCompleto;
  final String dni;
  final String email;
  final String telefono;
  final String? notas;
  final String iniciales;
  final String? fotoUrl;
  final bool tieneUsuario;
}

@immutable
class DtoReservaClienteAdmin {
  const DtoReservaClienteAdmin({
    required this.id,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
}

class ViewModelAdminClientes extends ViewModelAdminBase {
  ViewModelAdminClientes({
    required RepoClientes repoClientes,
    required RepoReservas repoReservas,
    required super.autenticacion,
  }) : _repoClientes = repoClientes,
       _repoReservas = repoReservas;

  final RepoClientes _repoClientes;
  final RepoReservas _repoReservas;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );
  final DateFormat _formatoFecha = DateFormat('dd/MM', 'es_ES');

  List<Cliente> _clientes = const <Cliente>[];
  DtoDetalleClienteAdmin? _detalle;
  List<DtoReservaClienteAdmin> _reservasCliente =
      const <DtoReservaClienteAdmin>[];
  String _busqueda = '';

  String get busqueda => _busqueda;
  DtoDetalleClienteAdmin? get detalle => _detalle;
  List<DtoReservaClienteAdmin> get reservasCliente => _reservasCliente;

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

  Future<void> cargarDetalleCliente(int id) async {
    _detalle = null;
    _reservasCliente = const <DtoReservaClienteAdmin>[];
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Cliente cliente = await _repoClientes.obtenerPorId(id, token);
      final List<Reserva> reservas = await _repoReservas.listarPorCliente(
        id,
        token,
      );
      _detalle = _crearDetalle(cliente);
      _reservasCliente = await _crearReservasCliente(token, reservas);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Cliente?> crearCliente({
    required String nombre,
    required String apellidos,
    required String dni,
    required String email,
    required String telefono,
    required String notas,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Cliente cliente = Cliente(
        nombre: nombre.trim(),
        apellidos: _valorOpcional(apellidos),
        dni: _valorOpcional(dni),
        email: _valorOpcional(email),
        telefono: _valorOpcional(telefono),
        notas: _valorOpcional(notas),
        tieneUsuario: false,
      );
      final Cliente creado = await _repoClientes.crear(cliente, token);
      await cargarClientes();
      return creado;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> darDeBajaCliente(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoClientes.darDeBaja(id, token);
      _detalle = null;
      _reservasCliente = const <DtoReservaClienteAdmin>[];
      await cargarClientes();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
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
      fotoUrl: cliente.fotoUrl,
      tieneUsuario: cliente.tieneUsuario,
    );
  }

  DtoDetalleClienteAdmin _crearDetalle(Cliente cliente) {
    final String nombreCompleto = _crearNombreCompleto(cliente);
    return DtoDetalleClienteAdmin(
      id: cliente.id ?? 0,
      nombre: cliente.nombre,
      apellidos: _textoConFallback(cliente.apellidos, 'Sin apellidos'),
      nombreCompleto: nombreCompleto,
      dni: _textoConFallback(cliente.dni, 'Sin DNI'),
      email: _textoConFallback(cliente.email, 'Sin email'),
      telefono: _textoConFallback(cliente.telefono, 'Sin teléfono'),
      notas: _textoOpcional(cliente.notas),
      iniciales: _crearIniciales(nombreCompleto),
      fotoUrl: cliente.fotoUrl,
      tieneUsuario: cliente.tieneUsuario,
    );
  }

  Future<bool> actualizarCliente({
    required int id,
    required String nombre,
    required String apellidos,
    required String dni,
    required String telefono,
    required String notas,
  }) async {
    iniciarCarga();
    try {
      final String token = leerTokenObligatorio();
      final String? emailOriginal = _textoOpcional(
        (_detalle?.email == 'Sin email') ? null : _detalle?.email,
      );
      final Cliente cliente = Cliente(
        id: id,
        nombre: nombre.trim(),
        apellidos: _valorOpcional(apellidos),
        dni: _valorOpcional(dni),
        email: emailOriginal,
        telefono: _valorOpcional(telefono),
        notas: _valorOpcional(notas),
        fotoUrl: _detalle?.fotoUrl,
        tieneUsuario: _detalle?.tieneUsuario ?? false,
      );
      await _repoClientes.actualizar(id, cliente, token);
      await cargarDetalleCliente(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<List<DtoReservaClienteAdmin>> _crearReservasCliente(
    String token,
    List<Reserva> reservas,
  ) async {
    final List<Reserva> ordenadas = List<Reserva>.from(reservas)
      ..sort(_compararReservas);
    final List<DtoReservaClienteAdmin> dtos = <DtoReservaClienteAdmin>[];
    for (final Reserva reserva in ordenadas) {
      final int? reservaId = reserva.id;
      if (reservaId == null) {
        continue;
      }
      final List<ReservaServicio> detalles = await _repoReservas
          .obtenerDetalles(reservaId, token);
      dtos.add(_crearReservaDto(reserva, detalles));
    }
    return dtos;
  }

  DtoReservaClienteAdmin _crearReservaDto(
    Reserva reserva,
    List<ReservaServicio> detalles,
  ) {
    final ReservaServicio? primerDetalle = detalles.isEmpty
        ? null
        : detalles.first;
    return DtoReservaClienteAdmin(
      id: reserva.id.toString(),
      servicio: detalles.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : detalles
                .map((detalle) => detalle.nombreServicio ?? 'Servicio')
                .join(', '),
      empleado: _textoConFallback(
        primerDetalle?.nombreEmpleado,
        'Sin empleado asignado',
      ),
      hora: '${_formatoFecha.format(reserva.fecha)} · '
          '${_textoConFallback(reserva.horaInicio, '--:--')}',
      precio: _formatoPrecio.format(_calcularTotal(detalles)),
      estado: reserva.estado ?? EstadoReserva.pendiente,
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

  int _compararReservas(Reserva a, Reserva b) {
    final int fecha = b.fecha.compareTo(a.fecha);
    if (fecha != 0) {
      return fecha;
    }
    return b.horaInicio.compareTo(a.horaInicio);
  }

  double _calcularTotal(List<ReservaServicio> detalles) {
    return detalles.fold<double>(
      0,
      (suma, detalle) =>
          suma + detalle.precioUnitario * (detalle.cantidad ?? 1),
    );
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

  String _resumenServicios(int total) {
    return total == 1 ? '1 servicio' : '$total servicios';
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }
}
