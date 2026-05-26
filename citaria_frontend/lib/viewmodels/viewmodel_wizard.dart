import 'package:citaria_frontend/data/models/disponibilidad.dart';
import 'package:citaria_frontend/data/models/periodo_disponibles.dart';
import 'package:citaria_frontend/data/models/franja_horaria.dart';
import 'package:citaria_frontend/data/models/reserva.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_disponibilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum OrigenWizard { cliente, admin }

@immutable
class DtoServicioWizard {
  const DtoServicioWizard({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionTexto,
    required this.precioTexto,
    required this.seleccionado,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String duracionTexto;
  final String precioTexto;
  final bool seleccionado;
}

@immutable
class DtoEmpleadoWizard {
  const DtoEmpleadoWizard({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.iniciales,
    required this.skills,
    required this.seleccionado,
  });

  final int? id;
  final String nombre;
  final String rol;
  final String iniciales;
  final List<String> skills;
  final bool seleccionado;
}

@immutable
class DtoDiaWizard {
  const DtoDiaWizard({
    required this.fecha,
    required this.dia,
    required this.esDelMes,
    required this.disponible,
    required this.seleccionado,
    required this.esHoy,
  });

  final DateTime fecha;
  final int dia;
  final bool esDelMes;
  final bool disponible;
  final bool seleccionado;
  final bool esHoy;
}

@immutable
class DtoFranjaWizard {
  const DtoFranjaWizard({
    required this.horaInicio,
    required this.horaFin,
    required this.horaTexto,
    required this.disponible,
    required this.seleccionada,
    required this.empleadosDisponibles,
  });

  final String horaInicio;
  final String horaFin;
  final String horaTexto;
  final bool disponible;
  final bool seleccionada;
  final int empleadosDisponibles;
}

@immutable
class DtoResumenWizard {
  const DtoResumenWizard({
    required this.serviciosTexto,
    required this.profesionalTexto,
    required this.profesionalIniciales,
    required this.fechaHoraTexto,
    required this.duracionTotalTexto,
    required this.precioTotalTexto,
    required this.puedeContinuar,
    required this.puedeConfirmar,
  });

  final String serviciosTexto;
  final String profesionalTexto;
  final String profesionalIniciales;
  final String fechaHoraTexto;
  final String duracionTotalTexto;
  final String precioTotalTexto;
  final bool puedeContinuar;
  final bool puedeConfirmar;
}

@immutable
class DtoReservaCreada {
  const DtoReservaCreada({
    required this.id,
    required this.fechaTexto,
    required this.horaTexto,
  });

  final int id;
  final String fechaTexto;
  final String horaTexto;
}

class ViewModelWizard extends ChangeNotifier {
  ViewModelWizard({
    required RepoCatalogo repoCatalogo,
    required RepoReservas repoReservas,
    required RepoDisponibilidad repoDisponibilidad,
    required String token,
    required int organizacionId,
    int? clienteIdExterno,
    OrigenWizard origen = OrigenWizard.cliente,
  }) : _repoCatalogo = repoCatalogo,
       _repoReservas = repoReservas,
       _repoDisponibilidad = repoDisponibilidad,
       _token = token,
       _organizacionId = organizacionId,
       _clienteIdExterno = clienteIdExterno,
       _origen = origen;

  final RepoCatalogo _repoCatalogo;
  final RepoReservas _repoReservas;
  final RepoDisponibilidad _repoDisponibilidad;
  final String _token;
  final int _organizacionId;
  final int? _clienteIdExterno;
  final OrigenWizard _origen;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );
  final DateFormat _formatoFecha = DateFormat('EEE d MMM', 'es_ES');

  bool _disposed = false;
  bool _cargando = false;
  String? _error;
  List<Servicio> _servicios = const <Servicio>[];
  Set<int> _serviciosSeleccionados = const <int>{};
  int? _empleadoId;
  DateTime _mesVisible = DateTime(DateTime.now().year, DateTime.now().month);
  Set<DateTime> _diasDisponiblesCache = const <DateTime>{};
  int _versionDiasCalendario = 0;
  DateTime? _fechaSeleccionada;
  List<FranjaHoraria> _franjas = const <FranjaHoraria>[];
  String? _horaSeleccionada;
  String _observaciones = '';
  DtoReservaCreada? _reservaCreada;

  bool get cargando => _cargando;
  String? get error => _error;
  OrigenWizard get origen => _origen;
  int get organizacionId => _organizacionId;
  DateTime get mesVisible => _mesVisible;
  DateTime? get fechaSeleccionada => _fechaSeleccionada;
  DtoReservaCreada? get reservaCreada => _reservaCreada;
  int get versionDiasCalendario => _versionDiasCalendario;

  List<DtoServicioWizard> get servicios {
    return _servicios.map(_crearDtoServicio).toList(growable: false);
  }

  DtoEmpleadoWizard get empleadoAutomatico {
    return DtoEmpleadoWizard(
      id: null,
      nombre: 'Asignación automática',
      rol: 'Te asignamos al mejor profesional disponible',
      iniciales: 'A',
      skills: const <String>[],
      seleccionado: _empleadoId == null,
    );
  }

  List<DtoDiaWizard> get diasCalendario {
    final DateTime primerDia = DateTime(_mesVisible.year, _mesVisible.month);
    final int offset = primerDia.weekday - 1;
    final int diasEnMes = DateTime(
      _mesVisible.year,
      _mesVisible.month + 1,
      0,
    ).day;
    final int totalCeldas = ((offset + diasEnMes) / 7).ceil() * 7;
    final DateTime hoy = _soloFecha(DateTime.now());

    return List<DtoDiaWizard>.generate(totalCeldas, (index) {
      final int dia = index - offset + 1;
      final bool esDelMes = dia >= 1 && dia <= diasEnMes;
      final DateTime fecha = esDelMes
          ? DateTime(_mesVisible.year, _mesVisible.month, dia)
          : DateTime(_mesVisible.year, _mesVisible.month, 1);
      final bool disponible = esDelMes &&
          _diasDisponiblesCache.contains(
              DateTime(_mesVisible.year, _mesVisible.month, dia));
      final DateTime? seleccionada = _fechaSeleccionada;
      return DtoDiaWizard(
        fecha: fecha,
        dia: esDelMes ? dia : 0,
        esDelMes: esDelMes,
        disponible: disponible,
        seleccionado:
            seleccionada != null &&
            _soloFecha(seleccionada) == _soloFecha(fecha),
        esHoy: _soloFecha(fecha) == hoy,
      );
    }, growable: false);
  }

  List<DtoFranjaWizard> get franjas {
    return _franjas.map(_crearDtoFranja).toList(growable: false);
  }

  DtoResumenWizard get resumen {
    final List<Servicio> seleccionados = _serviciosSeleccionados
        .map(_buscarServicio)
        .whereType<Servicio>()
        .toList(growable: false);
    final String serviciosTexto = seleccionados.isEmpty
        ? 'Sin servicios seleccionados'
        : seleccionados.map((servicio) => servicio.nombre).join(', ');
    final DateTime? fecha = _fechaSeleccionada;
    final String? hora = _horaSeleccionada;

    return DtoResumenWizard(
      serviciosTexto: serviciosTexto,
      profesionalTexto: 'Asignación automática',
      profesionalIniciales: 'A',
      fechaHoraTexto: fecha == null || hora == null
          ? 'Sin fecha y hora'
          : '${_capitalizar(_formatoFecha.format(fecha))} · '
                '${_formatearHora(hora)}',
      duracionTotalTexto: '$duracionTotalMinutos min',
      precioTotalTexto: _formatoPrecio.format(precioTotal),
      puedeContinuar: _serviciosSeleccionados.isNotEmpty,
      puedeConfirmar:
          _serviciosSeleccionados.isNotEmpty &&
          _fechaSeleccionada != null &&
          _horaSeleccionada != null,
    );
  }

  int get duracionTotalMinutos {
    return _serviciosSeleccionados
        .map(_buscarServicio)
        .whereType<Servicio>()
        .fold<int>(0, (suma, servicio) => suma + servicio.duracionMinutos);
  }

  double get precioTotal {
    return _serviciosSeleccionados
        .map(_buscarServicio)
        .whereType<Servicio>()
        .fold<double>(0, (suma, servicio) => suma + servicio.precio);
  }

  Future<void> inicializar({String? servicioPreseleccionado}) async {
    _setCargando(true);
    _limpiarError();

    try {
      _servicios = (await _repoCatalogo.listarServicios(_token))
          .where((servicio) => servicio.activo != false && servicio.id != null)
          .toList(growable: false);
      final int? idPreseleccionado = int.tryParse(
        servicioPreseleccionado ?? '',
      );
      if (idPreseleccionado != null) {
        _serviciosSeleccionados = <int>{idPreseleccionado};
      }
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> toggleServicio(int id) async {
    final Set<int> seleccionados = Set<int>.from(_serviciosSeleccionados);
    if (seleccionados.contains(id)) {
      seleccionados.remove(id);
    } else {
      seleccionados.add(id);
    }
    _serviciosSeleccionados = seleccionados;
    _fechaSeleccionada = null;
    _horaSeleccionada = null;
    _franjas = const <FranjaHoraria>[];
    _actualizarDiasDisponiblesCache(const <DateTime>{});
    notifyListeners();
  }

  void seleccionarEmpleadoAutomatico() {
    _empleadoId = null;
    notifyListeners();
  }

  Future<void> cargarDiasDisponibles() async {
    if (_serviciosSeleccionados.isEmpty) {
      _actualizarDiasDisponiblesCache(const <DateTime>{});
      notifyListeners();
      return;
    }

    _setCargando(true);
    _limpiarError();

    try {
      await _cargarDiasDisponiblesInterno();
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  void cambiarMes(int desplazamiento) {
    _mesVisible = DateTime(
      _mesVisible.year,
      _mesVisible.month + desplazamiento,
    );
    _fechaSeleccionada = null;
    _horaSeleccionada = null;
    _franjas = const <FranjaHoraria>[];
    notifyListeners();
  }

  Future<void> seleccionarFecha(DateTime fecha) async {
    if (!_diasDisponiblesCache.contains(_soloFecha(fecha))) return;
    _fechaSeleccionada = _soloFecha(fecha);
    _horaSeleccionada = null;
    notifyListeners();
    await cargarFranjas();
  }

  Future<void> cargarFranjas() async {
    final DateTime? fecha = _fechaSeleccionada;
    if (fecha == null || _serviciosSeleccionados.isEmpty) return;

    _setCargando(true);
    _limpiarError();

    try {
      final Disponibilidad disponibilidad = await _repoDisponibilidad.obtener(
        fecha,
        _serviciosSeleccionados.toList(growable: false),
        _token,
        empleadoId: _empleadoId,
      );
      _franjas = disponibilidad.franjas;
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  void seleccionarFranja(String horaInicio) {
    final FranjaHoraria? franja = _buscarFranja(horaInicio);
    if (franja == null || !franja.disponible) return;
    _horaSeleccionada = horaInicio;
    notifyListeners();
  }

  void actualizarObservaciones(String valor) {
    _observaciones = valor;
  }

  Future<bool> confirmarReserva(Sesion? sesion) async {
    if (_reservaCreada != null) return true;

    _setCargando(true);
    _limpiarError();

    try {
      final int? clienteSesion = sesion?.clienteId;
      final int? clienteId = _clienteIdExterno ?? clienteSesion;
      final DateTime? fecha = _fechaSeleccionada;
      final String? hora = _horaSeleccionada;
      if (clienteId == null) {
        throw StateError('No hay cliente seleccionado para la reserva.');
      }
      if (fecha == null || hora == null || _serviciosSeleccionados.isEmpty) {
        throw StateError('Completa todos los pasos antes de confirmar.');
      }

      final Reserva reserva = Reserva(
        fecha: fecha,
        horaInicio: hora,
        empleadoId: _empleadoId,
        servicioIds: _serviciosSeleccionados.toList(growable: false),
        notas: _observaciones.trim().isEmpty ? null : _observaciones.trim(),
      );
      final Reserva reservaCreada = await _repoReservas.crear(
        clienteId,
        reserva,
        _token,
      );
      _reservaCreada = _crearDtoReservaCreada(reservaCreada);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mensajeError(e));
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<void> _cargarDiasDisponiblesInterno() async {
    if (_serviciosSeleccionados.isEmpty) {
      _actualizarDiasDisponiblesCache(const <DateTime>{});
      return;
    }

    final DateTime hoy = DateTime.now();
    final DateTime fechaInicio = DateTime(hoy.year, hoy.month, hoy.day);
    // Último día del mes siguiente
    final DateTime fechaFin = DateTime(hoy.year, hoy.month + 2, 0);

    final PeriodoDisponibles periodo = await _repoDisponibilidad
        .obtenerDiasDisponiblesPeriodo(
          fechaInicio,
          fechaFin,
          _serviciosSeleccionados.toList(growable: false),
          _token,
          empleadoId: _empleadoId,
        );
    _actualizarDiasDisponiblesCache(periodo.fechasDisponibles.toSet());
  }

  void _actualizarDiasDisponiblesCache(Set<DateTime> fechas) {
    _diasDisponiblesCache = fechas;
    _versionDiasCalendario++;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  DtoServicioWizard _crearDtoServicio(Servicio servicio) {
    final int id = servicio.id ?? 0;
    return DtoServicioWizard(
      id: id,
      nombre: servicio.nombre,
      categoria: _texto(servicio.nombreCategoria, 'Sin categoría'),
      duracionTexto: '${servicio.duracionMinutos} min',
      precioTexto: _formatoPrecio.format(servicio.precio),
      seleccionado: _serviciosSeleccionados.contains(id),
    );
  }

  DtoFranjaWizard _crearDtoFranja(FranjaHoraria franja) {
    final bool disponible = franja.disponible && !_franjaYaPaso(franja);
    return DtoFranjaWizard(
      horaInicio: franja.horaInicio,
      horaFin: franja.horaFin,
      horaTexto: _formatearHora(franja.horaInicio),
      disponible: disponible,
      seleccionada: _horaSeleccionada == franja.horaInicio,
      empleadosDisponibles: franja.empleadosDisponibles,
    );
  }

  DtoReservaCreada _crearDtoReservaCreada(Reserva reserva) {
    return DtoReservaCreada(
      id: reserva.id ?? 0,
      fechaTexto: _capitalizar(_formatoFecha.format(reserva.fecha)),
      horaTexto: _formatearHora(reserva.horaInicio),
    );
  }

  Servicio? _buscarServicio(int id) {
    for (final Servicio servicio in _servicios) {
      if (servicio.id == id) return servicio;
    }
    return null;
  }

  FranjaHoraria? _buscarFranja(String horaInicio) {
    for (final FranjaHoraria franja in _franjas) {
      if (franja.horaInicio == horaInicio) return franja;
    }
    return null;
  }

  bool _franjaYaPaso(FranjaHoraria franja) {
    final DateTime? fecha = _fechaSeleccionada;
    if (fecha == null || _soloFecha(fecha) != _soloFecha(DateTime.now())) {
      return false;
    }
    final DateTime inicio = _combinarFechaHora(fecha, franja.horaInicio);
    return !inicio.isAfter(DateTime.now());
  }

  DateTime _combinarFechaHora(DateTime fecha, String hora) {
    final List<String> partes = hora.split(':');
    final int horaValor = int.tryParse(partes.first) ?? 0;
    final int minutoValor = partes.length > 1
        ? int.tryParse(partes[1]) ?? 0
        : 0;
    return DateTime(fecha.year, fecha.month, fecha.day, horaValor, minutoValor);
  }

  DateTime _soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  String _texto(String? valor, String fallback) {
    final String? limpio = valor?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto.substring(0, 1).toUpperCase()}${texto.substring(1)}';
  }

  String _formatearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) return hora;
    return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

  void _setCargando(bool valor) {
    if (_disposed) return;
    _cargando = valor;
    notifyListeners();
  }

  void _setError(String mensaje) {
    if (_disposed) return;
    _error = mensaje;
    notifyListeners();
  }

  void _limpiarError() {
    if (_disposed) return;
    _error = null;
  }
}
