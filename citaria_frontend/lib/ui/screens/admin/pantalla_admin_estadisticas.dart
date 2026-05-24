import 'dart:math' as math;

import 'package:citaria_frontend/data/repositories/repo_estadisticas.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/aviso_error.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
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
          body: _CuerpoEstadisticas(vmEstadisticas: vmEstadisticas),
        ),
      ),
    );
  }
}

// ── Cuerpo ────────────────────────────────────────────────────────────────────

class _CuerpoEstadisticas extends StatelessWidget {
  const _CuerpoEstadisticas({required this.vmEstadisticas});

  final ViewModelAdminEstadisticas vmEstadisticas;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (vmEstadisticas.cargando && vmEstadisticas.sinDatos) {
      return const SafeArea(
        bottom: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final String? error = vmEstadisticas.error;
    if (error != null && vmEstadisticas.sinDatos) {
      return SafeArea(
        bottom: false,
        child: EstadoCentrado(
          mensaje: error,
          accionTexto: 'Reintentar',
          onAccion: vmEstadisticas.refrescar,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                12,
                espaciado.padX,
                8,
              ),
              child: Text('Estadísticas', style: textTheme.displayLarge),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: vmEstadisticas.refrescar,
          child: ListView(
            padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
            children: [
              // ── KPIs ───────────────────────────────────────────────────────
              _TarjetaKpiDoble(
                kpi: vmEstadisticas.kpiReservas,
                icono: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 12),
              _TarjetaKpiDoble(
                kpi: vmEstadisticas.kpiFacturacion,
                icono: Icons.euro_outlined,
              ),
              const SizedBox(height: 12),
              _TarjetaServicioTop(servicio: vmEstadisticas.servicioTop),
              const SizedBox(height: 24),

              // ── Clientes ───────────────────────────────────────────────────
              _TarjetaGrafico(
                titulo: 'Clientes nuevos vs recurrentes',
                anoActivo: vmEstadisticas.anoGrafico(
                  GraficoAdmin.clientesVsRecurrentes,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.clientesVsRecurrentes,
                ),
                onAnoChanged: (ano) => vmEstadisticas.cambiarAnoGrafico(
                  GraficoAdmin.clientesVsRecurrentes,
                  ano,
                ),
                grafico: _GraficoClientesDobleLinea(
                  datos: vmEstadisticas.clientesNuevosVsRecurrentes,
                ),
                alturaGrafico: 220,
              ),
              const SizedBox(height: 16),
              _TarjetaGrafico(
                titulo: 'Fidelización mensual',
                anoActivo: vmEstadisticas.anoGrafico(
                  GraficoAdmin.fidelizacion,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.fidelizacion,
                ),
                onAnoChanged: (ano) => vmEstadisticas.cambiarAnoGrafico(
                  GraficoAdmin.fidelizacion,
                  ano,
                ),
                grafico: _GraficoFidelizacion(datos: vmEstadisticas.fidelizacion),
                alturaGrafico: 200,
              ),
              const SizedBox(height: 16),

              // ── Profesionales ──────────────────────────────────────────────
              _TarjetaGrafico(
                titulo: 'Rendimiento por profesional',
                periodoActivo: vmEstadisticas.periodoGrafico(
                  GraficoAdmin.rendimientoProfesional,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.rendimientoProfesional,
                ),
                onPeriodoChanged: (p) => vmEstadisticas.cambiarPeriodoGrafico(
                  GraficoAdmin.rendimientoProfesional,
                  p,
                ),
                grafico: _GraficoRendimientoProfesional(
                  datos: vmEstadisticas.rendimientoPorProfesional,
                ),
                alturaGrafico: 260,
              ),
              const SizedBox(height: 16),

              // ── Servicios ──────────────────────────────────────────────────
              _TarjetaGrafico(
                titulo: 'Servicios más solicitados',
                periodoActivo: vmEstadisticas.periodoGrafico(
                  GraficoAdmin.serviciosMasSolicitados,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.serviciosMasSolicitados,
                ),
                onPeriodoChanged: (p) => vmEstadisticas.cambiarPeriodoGrafico(
                  GraficoAdmin.serviciosMasSolicitados,
                  p,
                ),
                grafico: _RankingServicios(
                  datos: vmEstadisticas.serviciosMasSolicitados,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _TarjetaGrafico(
                titulo: 'Facturación por servicio',
                periodoActivo: vmEstadisticas.periodoGrafico(
                  GraficoAdmin.facturacionPorServicio,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.facturacionPorServicio,
                ),
                onPeriodoChanged: (p) => vmEstadisticas.cambiarPeriodoGrafico(
                  GraficoAdmin.facturacionPorServicio,
                  p,
                ),
                grafico: _RankingServicios(
                  datos: vmEstadisticas.importePorServicio,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              _TarjetaGrafico(
                titulo: 'Cancelaciones por servicio',
                periodoActivo: vmEstadisticas.periodoGrafico(
                  GraficoAdmin.cancelacionesPorServicio,
                ),
                cargandoGrafico: vmEstadisticas.cargandoGrafico(
                  GraficoAdmin.cancelacionesPorServicio,
                ),
                onPeriodoChanged: (p) => vmEstadisticas.cambiarPeriodoGrafico(
                  GraficoAdmin.cancelacionesPorServicio,
                  p,
                ),
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
        ),
      ),
    );
  }
}

// ── Selector de periodo compacto ──────────────────────────────────────────────

class _SelectorPeriodoCompacto extends StatelessWidget {
  const _SelectorPeriodoCompacto({
    required this.periodoActivo,
    required this.cargando,
    required this.onSeleccionar,
  });

  final PeriodoAdminEstadisticas periodoActivo;
  final bool cargando;
  final ValueChanged<PeriodoAdminEstadisticas> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ChipCompacto(
            etiqueta: 'Mes',
            activo: periodoActivo == PeriodoAdminEstadisticas.esteMes,
            onTap: cargando
                ? null
                : () => onSeleccionar(PeriodoAdminEstadisticas.esteMes),
          ),
          const SizedBox(width: 6),
          _ChipCompacto(
            etiqueta: '3 meses',
            activo: periodoActivo == PeriodoAdminEstadisticas.ultimos3Meses,
            onTap: cargando
                ? null
                : () => onSeleccionar(PeriodoAdminEstadisticas.ultimos3Meses),
          ),
          const SizedBox(width: 6),
          _ChipCompacto(
            etiqueta: '12 meses',
            activo: periodoActivo == PeriodoAdminEstadisticas.ultimos12Meses,
            onTap: cargando
                ? null
                : () => onSeleccionar(PeriodoAdminEstadisticas.ultimos12Meses),
          ),
        ],
      ),
    );
  }
}

class _SelectorAnoCompacto extends StatelessWidget {
  const _SelectorAnoCompacto({
    required this.anoActivo,
    required this.cargando,
    required this.onSeleccionar,
  });

  final int anoActivo;
  final bool cargando;
  final ValueChanged<int> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final int anoActual = DateTime.now().year;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i <= 5; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _ChipCompacto(
              etiqueta: '${anoActual - i}',
              activo: anoActivo == anoActual - i,
              onTap: cargando ? null : () => onSeleccionar(anoActual - i),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipCompacto extends StatelessWidget {
  const _ChipCompacto({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

// ── KPI doble ─────────────────────────────────────────────────────────────────

class _TarjetaKpiDoble extends StatelessWidget {
  const _TarjetaKpiDoble({required this.kpi, required this.icono});

  final DtoKpiDobleEstadisticaAdmin kpi;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 14, color: colorScheme.outline),
                const SizedBox(width: 6),
                Text(
                  kpi.titulo,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ColumnaKpi(
                      label: 'Hoy',
                      valor: kpi.valorHoy,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                  ),
                  VerticalDivider(
                    width: 32,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: _ColumnaKpi(
                      label: 'Este mes',
                      valor: kpi.valorMes,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnaKpi extends StatelessWidget {
  const _ColumnaKpi({
    required this.label,
    required this.valor,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final String valor;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
        const SizedBox(height: 4),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            valor,
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Servicio top ──────────────────────────────────────────────────────────────

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
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              servicio.detalle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contenedor de gráfico ─────────────────────────────────────────────────────

class _TarjetaGrafico extends StatelessWidget {
  const _TarjetaGrafico({
    required this.titulo,
    required this.grafico,
    this.alturaGrafico,
    this.periodoActivo,
    this.cargandoGrafico = false,
    this.onPeriodoChanged,
    this.anoActivo,
    this.onAnoChanged,
  });

  final String titulo;
  final Widget grafico;
  final double? alturaGrafico;
  final PeriodoAdminEstadisticas? periodoActivo;
  final bool cargandoGrafico;
  final ValueChanged<PeriodoAdminEstadisticas>? onPeriodoChanged;
  final int? anoActivo;
  final ValueChanged<int>? onAnoChanged;

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
            Row(
              children: [
                Expanded(
                  child: Text(titulo, style: textTheme.displaySmall),
                ),
                if (cargandoGrafico)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            if (onAnoChanged != null && anoActivo != null) ...[
              const SizedBox(height: 10),
              _SelectorAnoCompacto(
                anoActivo: anoActivo!,
                cargando: cargandoGrafico,
                onSeleccionar: onAnoChanged!,
              ),
            ] else if (onPeriodoChanged != null && periodoActivo != null) ...[
              const SizedBox(height: 10),
              _SelectorPeriodoCompacto(
                periodoActivo: periodoActivo!,
                cargando: cargandoGrafico,
                onSeleccionar: onPeriodoChanged!,
              ),
            ],
            const SizedBox(height: 12),
            alturaGrafico != null
                ? SizedBox(height: alturaGrafico!, child: grafico)
                : grafico,
          ],
        ),
      ),
    );
  }
}

// ── Gráfico: dos líneas (clientes nuevos vs recurrentes) ──────────────────────

class _GraficoClientesDobleLinea extends StatelessWidget {
  const _GraficoClientesDobleLinea({required this.datos});

  final List<DtoSerieMesEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EstadoVacioGrafico();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final double maxY = _maxSerieDoble(datos);
    final double intervalo = _intervaloEjeY(maxY);

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    datos.length,
                    (i) => FlSpot(i.toDouble(), datos[i].valor1),
                  ),
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 3,
                      color: colorScheme.primary,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.18),
                        colorScheme.primary.withValues(alpha: 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: List.generate(
                    datos.length,
                    (i) => FlSpot(i.toDouble(), datos[i].valor2),
                  ),
                  isCurved: true,
                  color: colorScheme.tertiary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 3,
                      color: colorScheme.tertiary,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: _titulosMeses(
                datos,
                textTheme,
                colorScheme,
                leftTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: intervalo,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        _etiquetaEjeY(value),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 9,
                        ),
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.inverseSurface,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final etiqueta =
                        spot.barIndex == 0 ? 'Nuevos' : 'Recurrentes';
                    return LineTooltipItem(
                      '$etiqueta: ${spot.y.round()}',
                      TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ItemLeyenda(color: colorScheme.primary, etiqueta: 'Nuevos'),
            const SizedBox(width: 16),
            _ItemLeyenda(color: colorScheme.tertiary, etiqueta: 'Recurrentes'),
          ],
        ),
      ],
    );
  }
}

// ── Gráfico: fidelización (línea con área + puntos + grid) ───────────────────

class _GraficoFidelizacion extends StatelessWidget {
  const _GraficoFidelizacion({required this.datos});

  final List<DtoSerieMesEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EstadoVacioGrafico();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final double maxY =
        math.max(100, _maxSerieSimple(datos.map((item) => item.valor2)));
    final double intervalo = _intervaloEjeY(maxY);

    return LineChart(
      LineChartData(
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              datos.length,
              (i) => FlSpot(i.toDouble(), datos[i].valor2),
            ),
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 3,
                color: colorScheme.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  colorScheme.primary.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: intervalo,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    '${value.round()}%',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => colorScheme.inverseSurface,
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${spot.y.round()}%',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Gráfico: rendimiento por profesional (barras agrupadas + facturación) ─────

class _GraficoRendimientoProfesional extends StatelessWidget {
  const _GraficoRendimientoProfesional({required this.datos});

  final List<DtoRendimientoProfesionalAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EstadoVacioGrafico();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final double maxY = datos
            .map((d) => math.max(d.reservas, d.cancelaciones))
            .fold<double>(0, math.max) *
        1.25;
    final double maxYSafe = maxY <= 0 ? 1 : maxY;
    final double intervalo = _intervaloEjeY(maxYSafe);

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxYSafe,
              groupsSpace: 16,
              barGroups: List.generate(datos.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: datos[i].reservas,
                      color: colorScheme.primary,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: datos[i].cancelaciones,
                      color: colorScheme.error,
                      width: 12,
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
                          _primerNombre(datos[idx].nombre),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: intervalo,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(
                          _etiquetaEjeY(value),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.inverseSurface,
                  getTooltipItem: (group, _, rod, rodIndex) {
                    final DtoRendimientoProfesionalAdmin item = datos[group.x];
                    if (rodIndex == 0) {
                      return BarTooltipItem(
                        'Reservas: ${item.reservas.round()}\n${item.facturacionTexto}',
                        TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return BarTooltipItem(
                      'Cancelaciones: ${item.cancelaciones.round()}',
                      TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Fila de facturación
        const SizedBox(height: 8),
        Row(
          children: [
            for (final item in datos)
              Expanded(
                child: Text(
                  item.facturacionTexto,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ItemLeyenda(color: colorScheme.primary, etiqueta: 'Reservas'),
            const SizedBox(width: 16),
            _ItemLeyenda(color: colorScheme.error, etiqueta: 'Cancelaciones'),
          ],
        ),
      ],
    );
  }
}

// ── Gráfico: ranking de servicios (barras de progreso) ────────────────────────

class _RankingServicios extends StatelessWidget {
  const _RankingServicios({required this.datos, required this.color});

  final List<DtoItemEstadisticaAdmin> datos;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EstadoVacioGrafico();

    final double maxValor =
        datos.map((d) => d.valor).fold<double>(0, math.max);

    return Column(
      children: [
        for (int i = 0; i < datos.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _FilaRanking(
            item: datos[i],
            maxValor: maxValor <= 0 ? 1 : maxValor,
            color: color,
          ),
        ],
      ],
    );
  }
}

class _FilaRanking extends StatelessWidget {
  const _FilaRanking({
    required this.item,
    required this.maxValor,
    required this.color,
  });

  final DtoItemEstadisticaAdmin item;
  final double maxValor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.nombre,
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.valorTexto,
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (item.valor / maxValor).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Gráfico: cancelaciones por servicio (donut) ───────────────────────────────

class _GraficoCancelacionesPorServicio extends StatelessWidget {
  const _GraficoCancelacionesPorServicio({required this.datos});

  final List<DtoItemEstadisticaAdmin> datos;

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EstadoVacioGrafico();

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

// ── Widgets comunes ───────────────────────────────────────────────────────────

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

// ── Helpers de fl_chart ───────────────────────────────────────────────────────

FlTitlesData _titulosMeses(
  List<DtoSerieMesEstadisticaAdmin> datos,
  TextTheme textTheme,
  ColorScheme colorScheme, {
  SideTitles? leftTitles,
}) {
  return FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final int idx = value.toInt();
          if (idx < 0 || idx >= datos.length) return const SizedBox.shrink();
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
    leftTitles: AxisTitles(
      sideTitles: leftTitles ?? const SideTitles(showTitles: false),
    ),
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
  if (maximo <= 0) return 1;
  return maximo * 1.2;
}

double _intervaloEjeY(double maxY) {
  if (maxY <= 0) return 1;
  final double rawInterval = maxY / 4;
  final int magnitude = (math.log(rawInterval) / math.ln10).floor();
  final double base = math.pow(10, magnitude).toDouble();
  for (final double step in <double>[1, 2, 2.5, 5, 10]) {
    final double candidate = step * base;
    if (candidate >= rawInterval) return candidate;
  }
  return base * 10;
}

String _etiquetaEjeY(double value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  return value.toInt().toString();
}

String _primerNombre(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+'));
  if (partes.isNotEmpty && partes[0].length >= 2) return partes[0];
  return nombre.length > 8 ? '${nombre.substring(0, 7)}.' : nombre;
}
