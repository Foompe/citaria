import 'package:citaria_frontend/data/models/estadistica_item.dart';
import 'package:citaria_frontend/data/models/estadistica_mes.dart';
import 'package:citaria_frontend/data/models/resumen_estadistica.dart';
import 'package:citaria_frontend/data/repositories/repo_estadisticas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum PeriodoAdminEstadisticas { esteMes, ultimos3Meses, ultimos12Meses }

enum GraficoAdmin {
  clientesVsRecurrentes,
  fidelizacion,
  rendimientoProfesional,
  serviciosMasSolicitados,
  facturacionPorServicio,
  cancelacionesPorServicio,
}

// ── DTOs ──────────────────────────────────────────────────────────────────────

@immutable
class DtoKpiEstadisticaAdmin {
  const DtoKpiEstadisticaAdmin({
    required this.label,
    required this.valor,
    required this.detalle,
  });

  final String label;
  final String valor;
  final String detalle;
}

@immutable
class DtoServicioTopEstadisticaAdmin {
  const DtoServicioTopEstadisticaAdmin({
    required this.nombre,
    required this.detalle,
  });

  final String nombre;
  final String detalle;
}

@immutable
class DtoSerieMesEstadisticaAdmin {
  const DtoSerieMesEstadisticaAdmin({
    required this.periodo,
    required this.valor1,
    required this.valor2,
  });

  final String periodo;
  final double valor1;
  final double valor2;
}

@immutable
class DtoItemEstadisticaAdmin {
  const DtoItemEstadisticaAdmin({
    required this.nombre,
    required this.valor,
    required this.valorTexto,
    required this.porcentaje,
    required this.porcentajeTexto,
  });

  final String nombre;
  final double valor;
  final String valorTexto;
  final double? porcentaje;
  final String? porcentajeTexto;
}

@immutable
class DtoKpiDobleEstadisticaAdmin {
  const DtoKpiDobleEstadisticaAdmin({
    required this.titulo,
    required this.valorHoy,
    required this.valorMes,
  });

  final String titulo;
  final String valorHoy;
  final String valorMes;
}

@immutable
class DtoRendimientoProfesionalAdmin {
  const DtoRendimientoProfesionalAdmin({
    required this.nombre,
    required this.reservas,
    required this.cancelaciones,
    required this.facturacionTexto,
  });

  final String nombre;
  final double reservas;
  final double cancelaciones;
  final String facturacionTexto;
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class ViewModelAdminEstadisticas extends ViewModelAdminBase {
  ViewModelAdminEstadisticas({
    required RepoEstadisticas repoEstadisticas,
    required super.autenticacion,
  }) : _repoEstadisticas = repoEstadisticas;

  final RepoEstadisticas _repoEstadisticas;
  final NumberFormat _formatoEntero = NumberFormat.decimalPattern('es_ES');
  final NumberFormat _formatoMoneda = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 0,
  );
  final NumberFormat _formatoPorcentaje = NumberFormat.decimalPattern('es_ES');

  // ── Estado por gráfico ─────────────────────────────────────────────────────
  final Map<GraficoAdmin, PeriodoAdminEstadisticas> _periodos = {
    for (final g in GraficoAdmin.values) g: PeriodoAdminEstadisticas.esteMes,
  };
  final Map<GraficoAdmin, int> _anos = {
    GraficoAdmin.clientesVsRecurrentes: DateTime.now().year,
    GraficoAdmin.fidelizacion: DateTime.now().year,
  };
  final Map<GraficoAdmin, Set<int>> _anosSinDatos = {
    GraficoAdmin.clientesVsRecurrentes: {},
    GraficoAdmin.fidelizacion: {},
  };
  final Map<GraficoAdmin, bool> _cargandoPorGrafico = {
    for (final g in GraficoAdmin.values) g: false,
  };

  // ── Datos ──────────────────────────────────────────────────────────────────
  ResumenEstadistica? _resumen;
  List<EstadisticaMes> _clientesNuevosVsRecurrentes = const [];
  List<EstadisticaMes> _fidelizacion = const [];
  DateTime _mesServicioTop =
      DateTime(DateTime.now().year, DateTime.now().month);
  List<EstadisticaItem> _servicioTopItems = const [];
  bool _cargandoServicioTop = false;
  List<EstadisticaItem> _reservasPorEmpleado = const [];
  List<EstadisticaItem> _importePorEmpleado = const [];
  List<EstadisticaItem> _cancelacionesPorEmpleado = const [];
  List<EstadisticaItem> _serviciosMasSolicitados = const [];
  List<EstadisticaItem> _importePorServicio = const [];
  List<EstadisticaItem> _cancelacionesPorServicio = const [];

  // ── Getters de estado ──────────────────────────────────────────────────────
  PeriodoAdminEstadisticas periodoGrafico(GraficoAdmin g) => _periodos[g]!;
  int anoGrafico(GraficoAdmin g) => _anos[g] ?? DateTime.now().year;
  Set<int> anosSinDatos(GraficoAdmin g) =>
      Set.unmodifiable(_anosSinDatos[g] ?? const {});
  bool cargandoGrafico(GraficoAdmin g) => _cargandoPorGrafico[g]!;
  DateTime get mesServicioTop => _mesServicioTop;
  bool get cargandoServicioTop => _cargandoServicioTop;

  bool get sinDatos =>
      !cargando &&
      error == null &&
      _resumen == null &&
      _clientesNuevosVsRecurrentes.isEmpty &&
      _fidelizacion.isEmpty &&
      _reservasPorEmpleado.isEmpty &&
      _importePorEmpleado.isEmpty &&
      _cancelacionesPorEmpleado.isEmpty &&
      _serviciosMasSolicitados.isEmpty &&
      _importePorServicio.isEmpty &&
      _cancelacionesPorServicio.isEmpty;

  // ── Getters de datos ───────────────────────────────────────────────────────
  DtoKpiDobleEstadisticaAdmin get kpiReservas => DtoKpiDobleEstadisticaAdmin(
    titulo: 'Reservas',
    valorHoy: _formatearEntero(_resumen?.reservasHoy),
    valorMes: _formatearEntero(_resumen?.reservasMes),
  );

  DtoKpiDobleEstadisticaAdmin get kpiFacturacion => DtoKpiDobleEstadisticaAdmin(
    titulo: 'Facturación',
    valorHoy: _formatearMoneda(_resumen?.facturacionHoy),
    valorMes: _formatearMoneda(_resumen?.facturacionMes),
  );

  DtoServicioTopEstadisticaAdmin get servicioTop {
    final EstadisticaItem? top =
        _servicioTopItems.isEmpty ? null : _servicioTopItems.first;
    final String nombre =
        _textoOpcional(top?.nombre) ??
        _textoOpcional(_resumen?.servicioMasSolicitadoMes) ??
        'Sin datos';
    final String detalle = top?.valor == null
        ? 'Sin reservas en el periodo'
        : '${_formatearEntero(top?.valor?.round())} reservas';
    return DtoServicioTopEstadisticaAdmin(nombre: nombre, detalle: detalle);
  }

  List<DtoSerieMesEstadisticaAdmin> get clientesNuevosVsRecurrentes =>
      _rellenarMesesAnuales(
        _clientesNuevosVsRecurrentes,
        _anos[GraficoAdmin.clientesVsRecurrentes] ?? DateTime.now().year,
      );

  List<DtoSerieMesEstadisticaAdmin> get fidelizacion =>
      _rellenarMesesAnuales(
        _fidelizacion,
        _anos[GraficoAdmin.fidelizacion] ?? DateTime.now().year,
      );

  List<DtoRendimientoProfesionalAdmin> get rendimientoPorProfesional {
    final Map<String, _RendimientoBuilder> mapa = {};
    for (final item in _reservasPorEmpleado) {
      final String nombre = _textoOpcional(item.nombre) ?? 'Sin nombre';
      mapa[nombre] = _RendimientoBuilder(
        nombre: nombre,
        reservas: item.valor ?? 0.0,
        facturacion: null,
        cancelaciones: 0.0,
      );
    }
    for (final item in _importePorEmpleado) {
      final String nombre = _textoOpcional(item.nombre) ?? 'Sin nombre';
      final _RendimientoBuilder? prev = mapa[nombre];
      mapa[nombre] = _RendimientoBuilder(
        nombre: nombre,
        reservas: prev?.reservas ?? 0.0,
        facturacion: item.valor,
        cancelaciones: prev?.cancelaciones ?? 0.0,
      );
    }
    for (final item in _cancelacionesPorEmpleado) {
      final String nombre = _textoOpcional(item.nombre) ?? 'Sin nombre';
      final _RendimientoBuilder? prev = mapa[nombre];
      mapa[nombre] = _RendimientoBuilder(
        nombre: nombre,
        reservas: prev?.reservas ?? 0.0,
        facturacion: prev?.facturacion,
        cancelaciones: item.valor ?? 0.0,
      );
    }
    return mapa.values
        .map(
          (b) => DtoRendimientoProfesionalAdmin(
            nombre: b.nombre,
            reservas: b.reservas,
            cancelaciones: b.cancelaciones,
            facturacionTexto: _formatearMoneda(b.facturacion),
          ),
        )
        .toList(growable: false);
  }

  List<DtoItemEstadisticaAdmin> get serviciosMasSolicitados =>
      _crearItems(_serviciosMasSolicitados, TipoValorEstadistica.cantidad);

  List<DtoItemEstadisticaAdmin> get importePorServicio =>
      _crearItems(_importePorServicio, TipoValorEstadistica.moneda);

  List<DtoItemEstadisticaAdmin> get cancelacionesPorServicio =>
      _crearItems(_cancelacionesPorServicio, TipoValorEstadistica.cantidad);

  // ── Carga inicial ──────────────────────────────────────────────────────────
  Future<void> cargarEstadisticas() async {
    iniciarCarga();
    for (final g in GraficoAdmin.values) {
      _cargandoPorGrafico[g] = true;
    }
    notifyListeners();

    Object? ultimoError;
    try {
      final String token = leerTokenObligatorio();
      final DateTime hoy = DateTime.now();

      // Wide range for year-based charts: probes last 5 years in one call
      final DateTime amplioDe = DateTime(hoy.year - 5, 1, 1);
      final DateTime amplioHasta = DateTime(hoy.year, hoy.month, hoy.day);

      final _RangoFechas rangoProf =
          _rangoGrafico(GraficoAdmin.rendimientoProfesional);
      final _RangoFechas rangoSvc =
          _rangoGrafico(GraficoAdmin.serviciosMasSolicitados);
      final _RangoFechas rangoFact =
          _rangoGrafico(GraficoAdmin.facturacionPorServicio);
      final _RangoFechas rangoCanc =
          _rangoGrafico(GraficoAdmin.cancelacionesPorServicio);

      // Se lanzan todas las peticiones a la vez (en paralelo)...
      final fResumen = _repoEstadisticas.obtenerResumen(token);
      final fClientes = _repoEstadisticas.clientesNuevosVsRecurrentes(
          amplioDe, amplioHasta, token);
      final fFidelizacion =
          _repoEstadisticas.fidelizacionClientes(amplioDe, amplioHasta, token);
      final fReservasProf = _repoEstadisticas.reservasPorEmpleado(
          rangoProf.desde, rangoProf.hasta, token);
      final fImporteProf = _repoEstadisticas.importePorEmpleado(
          rangoProf.desde, rangoProf.hasta, token);
      final fCancelProf = _repoEstadisticas.cancelacionesPorEmpleado(
          rangoProf.desde, rangoProf.hasta, token);
      final fServicios = _repoEstadisticas.serviciosMasSolicitados(
          rangoSvc.desde, rangoSvc.hasta, token);
      final fImporteSvc = _repoEstadisticas.importePorServicio(
          rangoFact.desde, rangoFact.hasta, token);
      final fCancelSvc = _repoEstadisticas.cancelacionesPorServicio(
          rangoCanc.desde, rangoCanc.hasta, token);

      // ...y cada respuesta se procesa por separado: el fallo de un gráfico
      // ya no descarta a los demás (antes un único Future.wait lo tumbaba todo).
      try {
        _resumen = await fResumen;
      } catch (e) {
        ultimoError = e;
      }

      List<EstadisticaMes> todosNvsR = const <EstadisticaMes>[];
      try {
        todosNvsR = await fClientes;
      } catch (e) {
        ultimoError = e;
      }

      List<EstadisticaMes> todosFid = const <EstadisticaMes>[];
      try {
        todosFid = await fFidelizacion;
      } catch (e) {
        ultimoError = e;
      }

      try {
        _reservasPorEmpleado = await fReservasProf;
      } catch (e) {
        ultimoError = e;
      }
      try {
        _importePorEmpleado = await fImporteProf;
      } catch (e) {
        ultimoError = e;
      }
      try {
        _cancelacionesPorEmpleado = await fCancelProf;
      } catch (e) {
        ultimoError = e;
      }
      try {
        _serviciosMasSolicitados = await fServicios;
      } catch (e) {
        ultimoError = e;
      }
      try {
        _importePorServicio = await fImporteSvc;
      } catch (e) {
        ultimoError = e;
      }
      try {
        _cancelacionesPorServicio = await fCancelSvc;
      } catch (e) {
        ultimoError = e;
      }

      // Determine which past years have data — no extra API calls
      _actualizarAnosSinDatos(
          todosNvsR, GraficoAdmin.clientesVsRecurrentes, hoy.year);
      _actualizarAnosSinDatos(todosFid, GraficoAdmin.fidelizacion, hoy.year);

      // Store only current year data for initial display
      _clientesNuevosVsRecurrentes = todosNvsR
          .where((m) => _extraerAnoNumero(m.periodo) == hoy.year)
          .toList();
      _fidelizacion = todosFid
          .where((m) => _extraerAnoNumero(m.periodo) == hoy.year)
          .toList();

      // Servicio top starts with current month data
      _mesServicioTop = DateTime(hoy.year, hoy.month);
      _servicioTopItems = _serviciosMasSolicitados;

      notifyListeners();
    } catch (e) {
      ultimoError = e;
    } finally {
      finalizarCarga();
      for (final g in GraficoAdmin.values) {
        _cargandoPorGrafico[g] = false;
      }
      // El error a pantalla completa solo se muestra si no llegó ningún dato;
      // con datos parciales se pintan los gráficos que sí cargaron.
      if (ultimoError != null && sinDatos) {
        registrarError(ultimoError);
      }
      notifyListeners();
    }
  }

  Future<void> refrescar() => cargarEstadisticas();

  // ── Cambio de periodo por gráfico ──────────────────────────────────────────
  Future<void> cambiarPeriodoGrafico(
    GraficoAdmin grafico,
    PeriodoAdminEstadisticas periodo,
  ) async {
    if (_periodos[grafico] == periodo) return;
    _periodos[grafico] = periodo;
    _cargandoPorGrafico[grafico] = true;
    notifyListeners();

    try {
      final String token = leerTokenObligatorio();
      final _RangoFechas rango = _crearRango(periodo);

      switch (grafico) {
        case GraficoAdmin.clientesVsRecurrentes:
          _clientesNuevosVsRecurrentes = await _repoEstadisticas
              .clientesNuevosVsRecurrentes(rango.desde, rango.hasta, token);
        case GraficoAdmin.fidelizacion:
          _fidelizacion = await _repoEstadisticas
              .fidelizacionClientes(rango.desde, rango.hasta, token);
        case GraficoAdmin.rendimientoProfesional:
          final res = await Future.wait<Object>([
            _repoEstadisticas.reservasPorEmpleado(rango.desde, rango.hasta, token),
            _repoEstadisticas.importePorEmpleado(rango.desde, rango.hasta, token),
            _repoEstadisticas.cancelacionesPorEmpleado(rango.desde, rango.hasta, token),
          ]);
          _reservasPorEmpleado = res[0] as List<EstadisticaItem>;
          _importePorEmpleado = res[1] as List<EstadisticaItem>;
          _cancelacionesPorEmpleado = res[2] as List<EstadisticaItem>;
        case GraficoAdmin.serviciosMasSolicitados:
          _serviciosMasSolicitados = await _repoEstadisticas
              .serviciosMasSolicitados(rango.desde, rango.hasta, token);
        case GraficoAdmin.facturacionPorServicio:
          _importePorServicio = await _repoEstadisticas
              .importePorServicio(rango.desde, rango.hasta, token);
        case GraficoAdmin.cancelacionesPorServicio:
          _cancelacionesPorServicio = await _repoEstadisticas
              .cancelacionesPorServicio(rango.desde, rango.hasta, token);
      }
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      _cargandoPorGrafico[grafico] = false;
      notifyListeners();
    }
  }

  // ── Cambio de año por gráfico ──────────────────────────────────────────────
  Future<void> cambiarAnoGrafico(GraficoAdmin grafico, int ano) async {
    if (_anos[grafico] == ano) return;
    _anos[grafico] = ano;
    _cargandoPorGrafico[grafico] = true;
    notifyListeners();

    try {
      final String token = leerTokenObligatorio();
      final _RangoFechas rango = _crearRangoAnual(ano);
      switch (grafico) {
        case GraficoAdmin.clientesVsRecurrentes:
          _clientesNuevosVsRecurrentes = await _repoEstadisticas
              .clientesNuevosVsRecurrentes(rango.desde, rango.hasta, token);
          if (_clientesNuevosVsRecurrentes.isEmpty &&
              ano != DateTime.now().year) {
            _anosSinDatos[grafico]?.add(ano);
            _anos[grafico] = DateTime.now().year;
            final _RangoFechas rangoActual =
                _crearRangoAnual(DateTime.now().year);
            _clientesNuevosVsRecurrentes = await _repoEstadisticas
                .clientesNuevosVsRecurrentes(
                    rangoActual.desde, rangoActual.hasta, token);
          }
        case GraficoAdmin.fidelizacion:
          _fidelizacion = await _repoEstadisticas
              .fidelizacionClientes(rango.desde, rango.hasta, token);
          if (_fidelizacion.isEmpty && ano != DateTime.now().year) {
            _anosSinDatos[grafico]?.add(ano);
            _anos[grafico] = DateTime.now().year;
            final _RangoFechas rangoActual =
                _crearRangoAnual(DateTime.now().year);
            _fidelizacion = await _repoEstadisticas
                .fidelizacionClientes(
                    rangoActual.desde, rangoActual.hasta, token);
          }
        default:
          break;
      }
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      _cargandoPorGrafico[grafico] = false;
      notifyListeners();
    }
  }

  // ── Cambio de mes en servicio top ──────────────────────────────────────────
  Future<void> cambiarMesServicioTop(DateTime mes) async {
    if (_mesServicioTop.year == mes.year && _mesServicioTop.month == mes.month) {
      return;
    }
    _mesServicioTop = mes;
    _cargandoServicioTop = true;
    notifyListeners();

    try {
      final String token = leerTokenObligatorio();
      final DateTime desde = DateTime(mes.year, mes.month);
      final DateTime hasta = DateTime(mes.year, mes.month + 1, 0);
      _servicioTopItems = await _repoEstadisticas
          .serviciosMasSolicitados(desde, hasta, token);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      _cargandoServicioTop = false;
      notifyListeners();
    }
  }

  // ── Helpers privados ───────────────────────────────────────────────────────
  _RangoFechas _rangoGrafico(GraficoAdmin g) {
    if (_anos.containsKey(g)) return _crearRangoAnual(_anos[g]!);
    return _crearRango(_periodos[g]!);
  }

  _RangoFechas _crearRango(PeriodoAdminEstadisticas periodo) {
    final DateTime hoy = DateTime.now();
    final DateTime hasta = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime desde = switch (periodo) {
      PeriodoAdminEstadisticas.esteMes => DateTime(hoy.year, hoy.month),
      PeriodoAdminEstadisticas.ultimos3Meses => DateTime(hoy.year, hoy.month - 2),
      PeriodoAdminEstadisticas.ultimos12Meses => DateTime(hoy.year, hoy.month - 11),
    };
    return _RangoFechas(desde: desde, hasta: hasta);
  }

  _RangoFechas _crearRangoAnual(int ano) {
    final DateTime hoy = DateTime.now();
    final DateTime desde = DateTime(ano, 1, 1);
    final DateTime hasta =
        ano == hoy.year ? DateTime(hoy.year, hoy.month, hoy.day) : DateTime(ano, 12, 31);
    return _RangoFechas(desde: desde, hasta: hasta);
  }

  void _actualizarAnosSinDatos(
    List<EstadisticaMes> datos,
    GraficoAdmin grafico,
    int anoActual,
  ) {
    final Set<int> presentes = {};
    for (final item in datos) {
      final int? ano = _extraerAnoNumero(item.periodo);
      if (ano != null) presentes.add(ano);
    }
    _anosSinDatos[grafico]?.clear();
    for (int i = 1; i <= 5; i++) {
      final int ano = anoActual - i;
      if (!presentes.contains(ano)) {
        _anosSinDatos[grafico]?.add(ano);
      }
    }
  }

  int? _extraerAnoNumero(String? periodo) {
    if (periodo == null) return null;
    final List<String> partes = periodo.trim().split('-');
    if (partes.isNotEmpty) return int.tryParse(partes[0]);
    return null;
  }

  List<DtoSerieMesEstadisticaAdmin> _rellenarMesesAnuales(
    List<EstadisticaMes> datos,
    int ano,
  ) {
    final DateTime hoy = DateTime.now();
    final int mesesHasta = ano == hoy.year ? hoy.month : 12;

    final Map<int, EstadisticaMes> porMes = {};
    for (final EstadisticaMes item in datos) {
      final int? mes = _extraerMesNumero(item.periodo);
      if (mes != null) porMes[mes] = item;
    }

    return [
      for (int m = 1; m <= mesesHasta; m++)
        DtoSerieMesEstadisticaAdmin(
          periodo: DateFormat.MMM('es_ES').format(DateTime(ano, m)),
          valor1: porMes[m]?.valor1 ?? 0.0,
          valor2: porMes[m]?.valor2 ?? 0.0,
        ),
    ];
  }

  int? _extraerMesNumero(String? periodo) {
    if (periodo == null) return null;
    final List<String> partes = periodo.trim().split('-');
    if (partes.length == 2) return int.tryParse(partes[1]);
    return null;
  }

  List<DtoItemEstadisticaAdmin> _crearItems(
    List<EstadisticaItem> items,
    TipoValorEstadistica tipo,
  ) {
    return items
        .map(
          (item) => DtoItemEstadisticaAdmin(
            nombre: _textoOpcional(item.nombre) ?? 'Sin nombre',
            valor: item.valor ?? 0,
            valorTexto: _formatearValor(item.valor, tipo),
            porcentaje: item.porcentaje,
            porcentajeTexto: item.porcentaje == null
                ? null
                : '${_formatoPorcentaje.format(item.porcentaje)}%',
          ),
        )
        .toList(growable: false);
  }

  String _formatearValor(double? valor, TipoValorEstadistica tipo) {
    return switch (tipo) {
      TipoValorEstadistica.cantidad => _formatearEntero(valor?.round()),
      TipoValorEstadistica.moneda => _formatearMoneda(valor),
    };
  }

  String _formatearEntero(int? valor) => _formatoEntero.format(valor ?? 0);
  String _formatearMoneda(double? valor) => _formatoMoneda.format(valor ?? 0);

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }
}

enum TipoValorEstadistica { cantidad, moneda }

class _RangoFechas {
  const _RangoFechas({required this.desde, required this.hasta});
  final DateTime desde;
  final DateTime hasta;
}

class _RendimientoBuilder {
  const _RendimientoBuilder({
    required this.nombre,
    required this.reservas,
    required this.facturacion,
    required this.cancelaciones,
  });

  final String nombre;
  final double reservas;
  final double? facturacion;
  final double cancelaciones;
}
