import 'dart:math' as math;

import 'package:citaria_frontend/data/repositories/repo_estadisticas.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/aviso_error.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_estadisticas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PantallaAdminEstadisticas extends StatefulWidget {
  const PantallaAdminEstadisticas({super.key});

  @override
  State<PantallaAdminEstadisticas> createState() =>
      _PantallaAdminEstadisticasState();
}

class _PantallaAdminEstadisticasState extends State<PantallaAdminEstadisticas> {
  late final ViewModelAdminEstadisticas _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminEstadisticas(
      repoEstadisticas: context.read<RepoEstadisticas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarEstadisticas();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminEstadisticas>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminEstadisticas>(
        builder: (context, vmEstadisticas, _) => Scaffold(
          drawer: const MenuLateralAdmin(),
          bottomNavigationBar: const BarraNavegacionAdmin(
            seccionActiva: SeccionAdmin.mas,
          ),
          appBar: const CabeceraPantalla(
            titulo: 'Estadísticas',
            mostrarAtras: false,
          ),
          body: _CuerpoEstadisticas(vmEstadisticas: vmEstadisticas),
        ),
      ),
    );
  }
}

class _CuerpoEstadisticas extends StatelessWidget {
  const _CuerpoEstadisticas({required this.vmEstadisticas});

  final ViewModelAdminEstadisticas vmEstadisticas;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;

    if (vmEstadisticas.cargando && vmEstadisticas.sinDatos) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmEstadisticas.error;
    if (error != null && vmEstadisticas.sinDatos) {
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmEstadisticas.refrescar,
      );
    }

    return RefreshIndicator(
      onRefresh: vmEstadisticas.refrescar,
      child: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
        children: [
          _SelectorPeriodo(
            periodoActivo: vmEstadisticas.periodoActivo,
            cargando: vmEstadisticas.cargando,
            onSeleccionar: vmEstadisticas.seleccionarPeriodo,
            onSeleccionarPersonalizado: () =>
                _seleccionarRangoPersonalizado(context, vmEstadisticas),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              for (final DtoKpiEstadisticaAdmin kpi in vmEstadisticas.kpis)
                _TarjetaKpi(kpi: kpi),
            ],
          ),
          const SizedBox(height: 16),
          _TarjetaServicioTop(servicio: vmEstadisticas.servicioTop),
          const SizedBox(height: 24),
          _TarjetaGrafico(
            titulo: 'Clientes nuevos vs recurrentes',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoNuevosVsRecurrentes(
              datos: vmEstadisticas.clientesNuevosVsRecurrentes,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Fidelización mensual',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoFidelizacion(datos: vmEstadisticas.fidelizacion),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Reservas por profesional',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoBarras(
              datos: vmEstadisticas.reservasPorEmpleado,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Facturación por profesional',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoBarras(
              datos: vmEstadisticas.importePorEmpleado,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Cancelaciones por profesional',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoBarras(
              datos: vmEstadisticas.cancelacionesPorEmpleado,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Servicios más solicitados',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoBarras(
              datos: vmEstadisticas.serviciosMasSolicitados,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Facturación por servicio',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoBarras(
              datos: vmEstadisticas.importePorServicio,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _TarjetaGrafico(
            titulo: 'Cancelaciones por servicio',
            subtitulo: vmEstadisticas.subtituloPeriodo,
            grafico: _GraficoCancelacionesPorServicio(
              datos: vmEstadisticas.cancelacionesPorServicio,
            ),
            alturaGrafico: 220,
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            AvisoError(mensaje: error),
          ],
          if (vmEstadisticas.cargando) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(color: colorScheme.primary),
          ],
        ],
      ),
    );
  }

  Future<void> _seleccionarRangoPersonalizado(
    BuildContext context,
    ViewModelAdminEstadisticas vmEstadisticas,
  ) async {
    final DateTime hoy = DateTime.now();
    final DateTime primerDiaPermitido = DateTime(hoy.year - 5);
    final DateTime ultimoDiaPermitido = DateTime(hoy.year + 1, 12, 31);
    final DateTimeRange rangoInicial = DateTimeRange(
      start:
          vmEstadisticas.desdePersonalizada ??
          DateTime(hoy.year, hoy.month - 2, hoy.day),
      end:
          vmEstadisticas.hastaPersonalizada ??
          DateTime(hoy.year, hoy.month, hoy.day),
    );

    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: primerDiaPermitido,
      lastDate: ultimoDiaPermitido,
      initialDateRange: rangoInicial,
    );

    if (rango == null) {
      return;
    }

    await vmEstadisticas.seleccionarRangoPersonalizado(
      desde: rango.start,
      hasta: rango.end,
    );
  }
}

class _SelectorPeriodo extends StatelessWidget {
  const _SelectorPeriodo({
    required this.periodoActivo,
    required this.cargando,
    required this.onSeleccionar,
    required this.onSeleccionarPersonalizado,
  });

  final PeriodoAdminEstadisticas periodoActivo;
  final bool cargando;
  final ValueChanged<PeriodoAdminEstadisticas> onSeleccionar;
  final VoidCallback onSeleccionarPersonalizado;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipPeriodo(
          etiqueta: 'Este mes',
          activo: periodoActivo == PeriodoAdminEstadisticas.esteMes,
          onTap: cargando
              ? null
              : () => onSeleccionar(PeriodoAdminEstadisticas.esteMes),
        ),
        _ChipPeriodo(
          etiqueta: 'Últimos 3 meses',
          activo: periodoActivo == PeriodoAdminEstadisticas.ultimos3Meses,
          onTap: cargando
              ? null
              : () => onSeleccionar(PeriodoAdminEstadisticas.ultimos3Meses),
        ),
        _ChipPeriodo(
          etiqueta: 'Últimos 12 meses',
          activo: periodoActivo == PeriodoAdminEstadisticas.ultimos12Meses,
          onTap: cargando
              ? null
              : () => onSeleccionar(PeriodoAdminEstadisticas.ultimos12Meses),
        ),
        _ChipPeriodo(
          etiqueta: 'Personalizado',
          activo: periodoActivo == PeriodoAdminEstadisticas.personalizado,
          onTap: cargando ? null : onSeleccionarPersonalizado,
        ),
      ],
    );
  }
}

class _ChipPeriodo extends StatelessWidget {
  const _ChipPeriodo({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  final String etiqueta;
  final bool activo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return InkWell(
      borderRadius: espaciado.radioPill,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: activo
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: espaciado.radioPill,
        ),
        child: Text(
          etiqueta,
          style: textTheme.labelSmall?.copyWith(
            color: activo ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _TarjetaKpi extends StatelessWidget {
  const _TarjetaKpi({required this.kpi});

  final DtoKpiEstadisticaAdmin kpi;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              kpi.label,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                kpi.valor,
                style: textTheme.displayMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            Text(
              kpi.detalle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaServicioTop extends StatelessWidget {
  const _TarjetaServicioTop({required this.servicio});

  final DtoServicioTopEstadisticaAdmin servicio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicio top del periodo',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servicio.nombre,
                    style: textTheme.displaySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              servicio.detalle,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaGrafico extends StatelessWidget {
  const _TarjetaGrafico({
    required this.titulo,
    required this.subtitulo,
    required this.grafico,
    this.alturaGrafico = 200,
  });

  final String titulo;
  final String subtitulo;
  final Widget grafico;
  final double alturaGrafico;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: textTheme.displaySmall),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            SizedBox(height: alturaGrafico, child: grafico),
          ],
        ),
      ),
    );
  }
}

class _GraficoNuevosVsRecurrentes extends StatelessWidget {
  const _GraficoNuevosVsRecurrentes({required this.datos});

  final List<DtoSerieMesEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const _EstadoVacioGrafico();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: _maxSerieDoble(datos),
              groupsSpace: 12,
              barGroups: List.generate(datos.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: datos[i].valor1,
                      color: colorScheme.primary,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: datos[i].valor2,
                      color: colorScheme.outline,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
              titlesData: _titulosMeses(datos, textTheme, colorScheme),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ItemLeyenda(color: colorScheme.primary, etiqueta: 'Nuevos'),
            const SizedBox(width: 16),
            _ItemLeyenda(color: colorScheme.outline, etiqueta: 'Recurrentes'),
          ],
        ),
      ],
    );
  }
}

class _GraficoFidelizacion extends StatelessWidget {
  const _GraficoFidelizacion({required this.datos});

  final List<DtoSerieMesEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const _EstadoVacioGrafico();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return LineChart(
      LineChartData(
        maxY: math.max(100, _maxSerieSimple(datos.map((item) => item.valor2))),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              datos.length,
              (i) => FlSpot(i.toDouble(), datos[i].valor2),
            ),
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 2,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.3),
                  colorScheme.primary.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _GraficoBarras extends StatelessWidget {
  const _GraficoBarras({required this.datos, required this.color});

  final List<DtoItemEstadisticaAdmin> datos;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const _EstadoVacioGrafico();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BarChart(
      BarChartData(
        maxY: _maxSerieSimple(datos.map((item) => item.valor)),
        barGroups: List.generate(datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: datos[i].valor,
                color: color,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _abreviar(datos[idx].nombre),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _GraficoCancelacionesPorServicio extends StatelessWidget {
  const _GraficoCancelacionesPorServicio({required this.datos});

  final List<DtoItemEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) {
      return const _EstadoVacioGrafico();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final List<Color> colores = <Color>[
      colorScheme.primary,
      Colors.purple,
      Colors.green,
      Colors.orange,
      colorScheme.error,
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              sections: List.generate(datos.length, (i) {
                final DtoItemEstadisticaAdmin item = datos[i];
                final double valor = item.porcentaje ?? item.valor;
                return PieChartSectionData(
                  value: valor <= 0 ? 1 : valor,
                  color: colores[i % colores.length],
                  title: item.porcentajeTexto ?? item.valorTexto,
                  titleStyle: textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  radius: 50,
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(datos.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _ItemLeyenda(
                  color: colores[i % colores.length],
                  etiqueta: datos[i].nombre,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  const _ItemLeyenda({required this.color, required this.etiqueta});

  final Color color;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            etiqueta,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EstadoVacioGrafico extends StatelessWidget {
  const _EstadoVacioGrafico();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        'Sin datos para el periodo',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
      ),
    );
  }
}


FlTitlesData _titulosMeses(
  List<DtoSerieMesEstadisticaAdmin> datos,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  return FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final int idx = value.toInt();
          if (idx < 0 || idx >= datos.length) {
            return const SizedBox.shrink();
          }
          return Text(
            datos[idx].periodo,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 10,
            ),
          );
        },
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

double _maxSerieDoble(List<DtoSerieMesEstadisticaAdmin> datos) {
  final Iterable<double> valores = datos.expand(
    (item) => <double>[item.valor1, item.valor2],
  );
  return _maxSerieSimple(valores);
}

double _maxSerieSimple(Iterable<double> valores) {
  final double maximo = valores.fold<double>(0, math.max);
  if (maximo <= 0) {
    return 1;
  }
  return maximo * 1.2;
}

String _abreviar(String texto) {
  final String limpio = texto.trim();
  if (limpio.length <= 12) {
    return limpio;
  }
  return '${limpio.substring(0, 11)}.';
}
