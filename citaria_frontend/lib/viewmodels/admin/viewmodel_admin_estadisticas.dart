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
  final Map<GraficoAdmin, bool> _cargandoPorGrafico = {
    for (final g in GraficoAdmin.values) g: false,
  };

  // ── Datos ──────────────────────────────────────────────────────────────────
  ResumenEstadistica? _resumen;
  List<EstadisticaMes> _clientesNuevosVsRecurrentes = const [];
  List<EstadisticaMes> _fidelizacion = const [];
  List<EstadisticaItem> _reservasPorEmpleado = const [];
  List<EstadisticaItem> _importePorEmpleado = const [];
  List<EstadisticaItem> _cancelacionesPorEmpleado = const [];
  List<EstadisticaItem> _serviciosMasSolicitados = const [];
  List<EstadisticaItem> _importePorServicio = const [];
  List<EstadisticaItem> _cancelacionesPorServicio = const [];

  // ── Getters de estado ──────────────────────────────────────────────────────
  PeriodoAdminEstadisticas periodoGrafico(GraficoAdmin g) => _periodos[g]!;
  int anoGrafico(GraficoAdmin g) => _anos[g] ?? DateTime.now().year;
  bool cargandoGrafico(GraficoAdmin g) => _cargandoPorGrafico[g]!;

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
    final EstadisticaItem? top = _serviciosMasSolicitados.isEmpty
        ? null
        : _serviciosMasSolicitados.first;
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
      _clientesNuevosVsRecurrentes.map(_crearSerieMes).toList(growable: false);

  List<DtoSerieMesEstadisticaAdmin> get fidelizacion =>
      _fidelizacion.map(_crearSerieMes).toList(growable: false);

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

    try {
      final String token = leerTokenObligatorio();

      final _RangoFechas rangoNvsR = _rangoGrafico(GraficoAdmin.clientesVsRecurrentes);
      final _RangoFechas rangoFid = _rangoGrafico(GraficoAdmin.fidelizacion);
      final _RangoFechas rangoProf = _rangoGrafico(GraficoAdmin.rendimientoProfesional);
      final _RangoFechas rangoSvc = _rangoGrafico(GraficoAdmin.serviciosMasSolicitados);
      final _RangoFechas rangoFact = _rangoGrafico(GraficoAdmin.facturacionPorServicio);
      final _RangoFechas rangoCanc = _rangoGrafico(GraficoAdmin.cancelacionesPorServicio);

      final resultados = await Future.wait<Object>(<Future<Object>>[
        _repoEstadisticas.obtenerResumen(token),
        _repoEstadisticas.clientesNuevosVsRecurrentes(rangoNvsR.desde, rangoNvsR.hasta, token),
        _repoEstadisticas.fidelizacionClientes(rangoFid.desde, rangoFid.hasta, token),
        _repoEstadisticas.reservasPorEmpleado(rangoProf.desde, rangoProf.hasta, token),
        _repoEstadisticas.importePorEmpleado(rangoProf.desde, rangoProf.hasta, token),
        _repoEstadisticas.cancelacionesPorEmpleado(rangoProf.desde, rangoProf.hasta, token),
        _repoEstadisticas.serviciosMasSolicitados(rangoSvc.desde, rangoSvc.hasta, token),
        _repoEstadisticas.importePorServicio(rangoFact.desde, rangoFact.hasta, token),
        _repoEstadisticas.cancelacionesPorServicio(rangoCanc.desde, rangoCanc.hasta, token),
      ]);

      _resumen = resultados[0] as ResumenEstadistica;
      _clientesNuevosVsRecurrentes = resultados[1] as List<EstadisticaMes>;
      _fidelizacion = resultados[2] as List<EstadisticaMes>;
      _reservasPorEmpleado = resultados[3] as List<EstadisticaItem>;
      _importePorEmpleado = resultados[4] as List<EstadisticaItem>;
      _cancelacionesPorEmpleado = resultados[5] as List<EstadisticaItem>;
      _serviciosMasSolicitados = resultados[6] as List<EstadisticaItem>;
      _importePorServicio = resultados[7] as List<EstadisticaItem>;
      _cancelacionesPorServicio = resultados[8] as List<EstadisticaItem>;
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
      for (final g in GraficoAdmin.values) {
        _cargandoPorGrafico[g] = false;
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
        case GraficoAdmin.fidelizacion:
          _fidelizacion = await _repoEstadisticas
              .fidelizacionClientes(rango.desde, rango.hasta, token);
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

  DtoSerieMesEstadisticaAdmin _crearSerieMes(EstadisticaMes mes) {
    return DtoSerieMesEstadisticaAdmin(
      periodo: _formatearPeriodo(mes.periodo),
      valor1: mes.valor1 ?? 0,
      valor2: mes.valor2 ?? 0,
    );
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

  String _formatearPeriodo(String? periodo) {
    final String? texto = _textoOpcional(periodo);
    if (texto == null) return '-';
    final List<String> partes = texto.split('-');
    if (partes.length == 2) {
      final int? mes = int.tryParse(partes[1]);
      if (mes != null && mes >= 1 && mes <= 12) {
        return DateFormat.MMM('es_ES').format(DateTime(2026, mes));
      }
    }
    return texto;
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
