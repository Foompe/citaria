import 'package:citaria_frontend/data/models/estadistica_item.dart';
import 'package:citaria_frontend/data/models/estadistica_mes.dart';
import 'package:citaria_frontend/data/models/resumen_estadistica.dart';
import 'package:citaria_frontend/data/repositories/repo_estadisticas.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum PeriodoAdminEstadisticas {
  esteMes,
  ultimos3Meses,
  ultimos12Meses,
  personalizado,
}

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
  final DateFormat _formatoRango = DateFormat('d MMM yyyy', 'es_ES');

  PeriodoAdminEstadisticas _periodoActivo = PeriodoAdminEstadisticas.esteMes;
  DateTime? _desdePersonalizada;
  DateTime? _hastaPersonalizada;
  ResumenEstadistica? _resumen;
  List<EstadisticaMes> _clientesNuevosVsRecurrentes = const <EstadisticaMes>[];
  List<EstadisticaMes> _fidelizacion = const <EstadisticaMes>[];
  List<EstadisticaItem> _reservasPorEmpleado = const <EstadisticaItem>[];
  List<EstadisticaItem> _importePorEmpleado = const <EstadisticaItem>[];
  List<EstadisticaItem> _cancelacionesPorEmpleado = const <EstadisticaItem>[];
  List<EstadisticaItem> _serviciosMasSolicitados = const <EstadisticaItem>[];
  List<EstadisticaItem> _importePorServicio = const <EstadisticaItem>[];
  List<EstadisticaItem> _cancelacionesPorServicio = const <EstadisticaItem>[];

  PeriodoAdminEstadisticas get periodoActivo => _periodoActivo;
  DateTime? get desdePersonalizada => _desdePersonalizada;
  DateTime? get hastaPersonalizada => _hastaPersonalizada;

  String get subtituloPeriodo => switch (_periodoActivo) {
    PeriodoAdminEstadisticas.esteMes => 'Este mes',
    PeriodoAdminEstadisticas.ultimos3Meses => 'Últimos 3 meses',
    PeriodoAdminEstadisticas.ultimos12Meses => 'Últimos 12 meses',
    PeriodoAdminEstadisticas.personalizado => _subtituloPersonalizado(),
  };

  List<DtoKpiEstadisticaAdmin> get kpis {
    final ResumenEstadistica? resumen = _resumen;
    return <DtoKpiEstadisticaAdmin>[
      DtoKpiEstadisticaAdmin(
        label: 'Reservas hoy',
        valor: _formatearEntero(resumen?.reservasHoy),
        detalle: 'Día actual',
      ),
      DtoKpiEstadisticaAdmin(
        label: 'Reservas mes',
        valor: _formatearEntero(resumen?.reservasMes),
        detalle: 'Mes actual',
      ),
      DtoKpiEstadisticaAdmin(
        label: 'Facturación hoy',
        valor: _formatearMoneda(resumen?.facturacionHoy),
        detalle: 'Día actual',
      ),
      DtoKpiEstadisticaAdmin(
        label: 'Facturación mes',
        valor: _formatearMoneda(resumen?.facturacionMes),
        detalle: 'Mes actual',
      ),
    ];
  }

  DtoServicioTopEstadisticaAdmin get servicioTop {
    final EstadisticaItem? top = _serviciosMasSolicitados.isEmpty
        ? null
        : _serviciosMasSolicitados.first;
    final String? nombreResumen = _textoOpcional(
      _resumen?.servicioMasSolicitadoMes,
    );
    final String nombre =
        _textoOpcional(top?.nombre) ?? nombreResumen ?? 'Sin datos';
    final String detalle = top?.valor == null
        ? 'Sin reservas en el periodo'
        : '${_formatearEntero(top?.valor?.round())} reservas';

    return DtoServicioTopEstadisticaAdmin(nombre: nombre, detalle: detalle);
  }

  List<DtoSerieMesEstadisticaAdmin> get clientesNuevosVsRecurrentes =>
      _clientesNuevosVsRecurrentes.map(_crearSerieMes).toList(growable: false);

  List<DtoSerieMesEstadisticaAdmin> get fidelizacion =>
      _fidelizacion.map(_crearSerieMes).toList(growable: false);

  List<DtoItemEstadisticaAdmin> get reservasPorEmpleado =>
      _crearItems(_reservasPorEmpleado, TipoValorEstadistica.cantidad);

  List<DtoItemEstadisticaAdmin> get importePorEmpleado =>
      _crearItems(_importePorEmpleado, TipoValorEstadistica.moneda);

  List<DtoItemEstadisticaAdmin> get cancelacionesPorEmpleado =>
      _crearItems(_cancelacionesPorEmpleado, TipoValorEstadistica.cantidad);

  List<DtoItemEstadisticaAdmin> get serviciosMasSolicitados =>
      _crearItems(_serviciosMasSolicitados, TipoValorEstadistica.cantidad);

  List<DtoItemEstadisticaAdmin> get importePorServicio =>
      _crearItems(_importePorServicio, TipoValorEstadistica.moneda);

  List<DtoItemEstadisticaAdmin> get cancelacionesPorServicio =>
      _crearItems(_cancelacionesPorServicio, TipoValorEstadistica.cantidad);

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

  Future<void> cargarEstadisticas() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final _RangoFechas rango = _crearRango(_periodoActivo);

      final resultados = await Future.wait<Object>(<Future<Object>>[
        _repoEstadisticas.obtenerResumen(token),
        _repoEstadisticas.clientesNuevosVsRecurrentes(
          rango.desde,
          rango.hasta,
          token,
        ),
        _repoEstadisticas.fidelizacionClientes(rango.desde, rango.hasta, token),
        _repoEstadisticas.reservasPorEmpleado(rango.desde, rango.hasta, token),
        _repoEstadisticas.importePorEmpleado(rango.desde, rango.hasta, token),
        _repoEstadisticas.cancelacionesPorEmpleado(
          rango.desde,
          rango.hasta,
          token,
        ),
        _repoEstadisticas.serviciosMasSolicitados(
          rango.desde,
          rango.hasta,
          token,
        ),
        _repoEstadisticas.importePorServicio(rango.desde, rango.hasta, token),
        _repoEstadisticas.cancelacionesPorServicio(
          rango.desde,
          rango.hasta,
          token,
        ),
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
    }
  }

  Future<void> refrescar() {
    return cargarEstadisticas();
  }

  Future<void> seleccionarPeriodo(PeriodoAdminEstadisticas periodo) async {
    if (_periodoActivo == periodo) {
      return;
    }
    _periodoActivo = periodo;
    notifyListeners();
    await cargarEstadisticas();
  }

  Future<void> seleccionarRangoPersonalizado({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final DateTime desdeNormalizada = DateTime(
      desde.year,
      desde.month,
      desde.day,
    );
    final DateTime hastaNormalizada = DateTime(
      hasta.year,
      hasta.month,
      hasta.day,
    );

    if (hastaNormalizada.isBefore(desdeNormalizada)) {
      registrarError('La fecha final no puede ser anterior a la inicial.');
      return;
    }

    _desdePersonalizada = desdeNormalizada;
    _hastaPersonalizada = hastaNormalizada;
    _periodoActivo = PeriodoAdminEstadisticas.personalizado;
    notifyListeners();
    await cargarEstadisticas();
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

  _RangoFechas _crearRango(PeriodoAdminEstadisticas periodo) {
    final DateTime hoy = DateTime.now();
    final DateTime hasta = DateTime(hoy.year, hoy.month, hoy.day);
    if (periodo == PeriodoAdminEstadisticas.personalizado &&
        _desdePersonalizada != null &&
        _hastaPersonalizada != null) {
      return _RangoFechas(
        desde: _desdePersonalizada!,
        hasta: _hastaPersonalizada!,
      );
    }

    final DateTime desde = switch (periodo) {
      PeriodoAdminEstadisticas.esteMes => DateTime(hoy.year, hoy.month),
      PeriodoAdminEstadisticas.ultimos3Meses => DateTime(
        hoy.year,
        hoy.month - 2,
      ),
      PeriodoAdminEstadisticas.ultimos12Meses => DateTime(
        hoy.year,
        hoy.month - 11,
      ),
      PeriodoAdminEstadisticas.personalizado => DateTime(
        hoy.year,
        hoy.month - 11,
      ),
    };
    return _RangoFechas(desde: desde, hasta: hasta);
  }

  String _subtituloPersonalizado() {
    final DateTime? desde = _desdePersonalizada;
    final DateTime? hasta = _hastaPersonalizada;
    if (desde == null || hasta == null) {
      return 'Rango personalizado';
    }
    return '${_formatoRango.format(desde)} - ${_formatoRango.format(hasta)}';
  }

  String _formatearPeriodo(String? periodo) {
    final String? texto = _textoOpcional(periodo);
    if (texto == null) {
      return '-';
    }
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

  String _formatearEntero(int? valor) {
    return _formatoEntero.format(valor ?? 0);
  }

  String _formatearMoneda(double? valor) {
    return _formatoMoneda.format(valor ?? 0);
  }

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
