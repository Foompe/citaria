import 'dart:async';

import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/cliente.dart';
import 'package:citaria_frontend/data/models/pagina_clientes.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/dto/admin/dto_cliente_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_detalle_cliente_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_reserva_cliente_admin.dart';
import 'package:citaria_frontend/utils/formato_hora.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_base.dart';
import 'package:intl/intl.dart';

/// Gestiona los clientes en admin: listado y detalle de cada cliente.
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
  Timer? _debounce;
  int _paginaActual = 0;
  bool _hayMasPaginas = false;

  String get busqueda => _busqueda;
  DtoDetalleClienteAdmin? get detalle => _detalle;
  List<DtoReservaClienteAdmin> get reservasCliente => _reservasCliente;
  bool get hayMasPaginas => _hayMasPaginas;

  List<DtoClienteAdmin> get clientes {
    return _clientes
        .where((c) => c.id != null)
        .map(_crearDto)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> cargarClientes() async {
    iniciarCarga();
    _paginaActual = 0;
    _hayMasPaginas = false;

    try {
      final String token = leerTokenObligatorio();
      final PaginaClientes resultado = await _repoClientes.listarAdminPaginado(
        _busqueda.isEmpty ? null : _busqueda,
        0,
        token,
      );
      _clientes = resultado.content;
      _hayMasPaginas = !resultado.last;
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarMas() async {
    if (!_hayMasPaginas) return;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final PaginaClientes resultado = await _repoClientes.listarAdminPaginado(
        _busqueda.isEmpty ? null : _busqueda,
        _paginaActual + 1,
        token,
      );
      _paginaActual++;
      _clientes = <Cliente>[..._clientes, ...resultado.content];
      _hayMasPaginas = !resultado.last;
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
      final resultados = await Future.wait(<Future<Object>>[
        _repoClientes.obtenerPorId(id, token),
        _repoReservas.listarPorCliente(id, token),
      ]);
      final cliente = resultados[0] as Cliente;
      final reservas = resultados[1] as List<Reserva>;
      _detalle = _crearDetalle(cliente);
      _reservasCliente = _crearReservasCliente(reservas);
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

  Future<bool> subirFoto({
    required int id,
    required List<int> bytes,
    required String nombreFichero,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoClientes.subirFoto(id, bytes, nombreFichero, token);
      await cargarDetalleCliente(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
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
    if (_busqueda == valor) return;
    _busqueda = valor;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), cargarClientes);
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

  List<DtoReservaClienteAdmin> _crearReservasCliente(List<Reserva> reservas) {
    final List<Reserva> ordenadas = List<Reserva>.from(reservas)
      ..sort(_compararReservas);
    return ordenadas
        .where((r) => r.id != null)
        .map((r) => _crearReservaDto(r, r.lineas))
        .toList(growable: false);
  }

  DtoReservaClienteAdmin _crearReservaDto(
    Reserva reserva,
    List<ReservaServicio> detalles,
  ) {
    final ReservaServicio? primerDetalle =
        detalles.isEmpty ? null : detalles.first;
    return DtoReservaClienteAdmin(
      id: reserva.id.toString(),
      servicio: detalles.isEmpty
          ? _resumenServicios(reserva.servicioIds.length)
          : detalles.map((d) => d.nombreServicio ?? 'Servicio').join(', '),
      empleado: _textoConFallback(
        primerDetalle?.nombreEmpleado,
        'Sin empleado asignado',
      ),
      hora: '${_formatoFecha.format(reserva.fecha)} · '
          '${reserva.horaInicio.isEmpty ? '--:--' : formatearHoraHm(reserva.horaInicio)}',
      precio: _formatoPrecio.format(_calcularTotal(detalles)),
      estado: reserva.estado ?? EstadoReserva.pendiente,
    );
  }

  int _compararReservas(Reserva a, Reserva b) {
    final int fecha = b.fecha.compareTo(a.fecha);
    if (fecha != 0) return fecha;
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
    if (partes.isEmpty) return 'C';
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) return primera;
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String _resumenServicios(int total) {
    return total == 1 ? '1 servicio' : '$total servicios';
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }
}
