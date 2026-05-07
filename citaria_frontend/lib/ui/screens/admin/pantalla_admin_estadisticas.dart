import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Enumerado de período ──────────────────────────────────────────────────────

enum _Periodo { esteMes, ultimos3Meses, personalizado }

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P34 — Estadísticas del negocio con gráficos fl_chart.
///
/// Todos los datos están hardcodeados.
/// TODO: datos reales de API
class PantallaAdminEstadisticas extends StatefulWidget {
  const PantallaAdminEstadisticas({super.key});

  @override
  State<PantallaAdminEstadisticas> createState() =>
      _PantallaAdminEstadisticasState();
}

class _PantallaAdminEstadisticasState
    extends State<PantallaAdminEstadisticas> {
  _Periodo _periodoActivo = _Periodo.esteMes;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.mas,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX, 16, espaciado.padX, 32,
        ),
        children: [
          // ── Cabecera manual ────────────────────────────────────────────────
          Text('Estadísticas', style: textTheme.displayLarge),
          const SizedBox(height: 12),

          // Chips de período
          Wrap(
            spacing: 8,
            children: [
              _ChipPeriodo(
                etiqueta: 'Este mes',
                activo: _periodoActivo == _Periodo.esteMes,
                onTap: () =>
                    setState(() => _periodoActivo = _Periodo.esteMes),
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
              _ChipPeriodo(
                etiqueta: 'Últimos 3 meses',
                activo: _periodoActivo == _Periodo.ultimos3Meses,
                onTap: () =>
                    setState(() => _periodoActivo = _Periodo.ultimos3Meses),
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
              _ChipPeriodo(
                etiqueta: 'Personalizado',
                activo: _periodoActivo == _Periodo.personalizado,
                onTap: () =>
                    setState(() => _periodoActivo = _Periodo.personalizado),
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── KPIs 2×2 ──────────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _TarjetaKpi(
                label: 'Reservas hoy',
                valor: '14',
                delta: '+3 vs ayer',
              ),
              _TarjetaKpi(
                label: 'Reservas mes',
                valor: '287',
                delta: '+12% vs mes ant.',
              ),
              _TarjetaKpi(
                label: 'Facturación hoy',
                valor: '640 €',
                delta: '+85 €',
              ),
              _TarjetaKpi(
                label: 'Facturación mes',
                valor: '11.2k €',
                delta: '+18%',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta servicio top
          _TarjetaServicioTop(
            colorScheme: colorScheme,
            textTheme: textTheme,
            espaciado: espaciado,
          ),
          const SizedBox(height: 24),

          // ── Gráficos ───────────────────────────────────────────────────────
          _TarjetaGrafico(
            titulo: 'Clientes nuevos vs recurrentes',
            subtitulo: 'Últimos 6 meses',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoNuevosVsRecurrentes(
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Fidelización mensual',
            subtitulo: 'Últimos 12 meses',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoFidelizacion(colorScheme: colorScheme),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Reservas por profesional',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoReservasPorProfesional(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Facturación por profesional',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoFacturacionPorProfesional(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Cancelaciones por profesional',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoCancelacionesPorProfesional(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Servicios más solicitados',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoServiciosMasSolicitados(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Facturación por servicio',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoFacturacionPorServicio(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          const SizedBox(height: 16),

          _TarjetaGrafico(
            titulo: 'Cancelaciones por servicio',
            subtitulo: 'Este mes',
            espaciado: espaciado,
            textTheme: textTheme,
            colorScheme: colorScheme,
            grafico: _GraficoCancelacionesPorServicio(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            alturaGrafico: 220,
          ),
        ],
      ),
    );
  }
}

// ── _TarjetaKpi ───────────────────────────────────────────────────────────────

class _TarjetaKpi extends StatelessWidget {
  const _TarjetaKpi({
    required this.label,
    required this.valor,
    required this.delta,
  });

  final String label;
  final String valor;
  final String delta;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              valor,
              style: textTheme.displayMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            Text(
              delta,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _TarjetaServicioTop ───────────────────────────────────────────────────────

class _TarjetaServicioTop extends StatelessWidget {
  const _TarjetaServicioTop({
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servicio top del mes',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                // TODO: servicio top real de API
                Text('Lavado Premium', style: textTheme.displaySmall),
              ],
            ),
            Text(
              '98 reservas',
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

// ── _ChipPeriodo ──────────────────────────────────────────────────────────────

class _ChipPeriodo extends StatelessWidget {
  const _ChipPeriodo({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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

// ── _TarjetaGrafico ───────────────────────────────────────────────────────────

class _TarjetaGrafico extends StatelessWidget {
  const _TarjetaGrafico({
    required this.titulo,
    required this.subtitulo,
    required this.grafico,
    required this.espaciado,
    required this.textTheme,
    required this.colorScheme,
    this.alturaGrafico = 200,
  });

  final String titulo;
  final String subtitulo;
  final Widget grafico;
  final EspaciadoCitaria espaciado;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final double alturaGrafico;

  @override
  Widget build(BuildContext context) {
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
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: alturaGrafico, child: grafico),
          ],
        ),
      ),
    );
  }
}

// ── Gráfico 1: Clientes nuevos vs recurrentes (BarChart doble) ────────────────

class _GraficoNuevosVsRecurrentes extends StatelessWidget {
  const _GraficoNuevosVsRecurrentes({required this.colorScheme});

  final ColorScheme colorScheme;

  // Datos: Nov(18,32) Dic(24,38) Ene(22,41) Feb(28,45) Mar(31,52) Abr(26,58)
  // TODO: datos reales de API
  static const List<(double, double)> _datos = [
    (18, 32), (24, 38), (22, 41), (28, 45), (31, 52), (26, 58),
  ];
  static const List<String> _meses = [
    'Nov', 'Dic', 'Ene', 'Feb', 'Mar', 'Abr',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              groupsSpace: 12,
              barGroups: List.generate(_datos.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _datos[i].$1,
                      color: colorScheme.primary,
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: _datos[i].$2,
                      color: colorScheme.outline,
                      width: 10,
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
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _meses.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _meses[idx],
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 10,
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
          ),
        ),
        const SizedBox(height: 8),
        // Leyenda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ItemLeyenda(
              color: colorScheme.primary,
              etiqueta: 'Nuevos',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 16),
            _ItemLeyenda(
              color: colorScheme.outline,
              etiqueta: 'Recurrentes',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Gráfico 2: Fidelización mensual (LineChart) ───────────────────────────────

class _GraficoFidelizacion extends StatelessWidget {
  const _GraficoFidelizacion({required this.colorScheme});

  final ColorScheme colorScheme;

  // TODO: datos reales de API
  static const List<double> _puntos = [
    20, 35, 30, 50, 45, 70, 65, 85, 78, 92, 88, 105,
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _puntos.length,
              (i) => FlSpot(i.toDouble(), _puntos[i]),
            ),
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 2,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.3),
                  colorScheme.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(
          bottomTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ── Gráfico 3: Reservas por profesional (BarChart horizontal) ─────────────────

class _GraficoReservasPorProfesional extends StatelessWidget {
  const _GraficoReservasPorProfesional({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  static const List<(String, double)> _datos = [
    ('Carlos M.', 112),
    ('Ana R.', 96),
    ('David L.', 79),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _datos[i].$2,
                color: colorScheme.primary,
                width: 20,
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
                final idx = value.toInt();
                if (idx < 0 || idx >= _datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _datos[idx].$1,
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

// ── Gráfico 4: Facturación por profesional (BarChart) ────────────────────────

class _GraficoFacturacionPorProfesional extends StatelessWidget {
  const _GraficoFacturacionPorProfesional({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  static const List<(String, double)> _datos = [
    ('Carlos', 4800),
    ('Ana', 3200),
    ('David', 2400),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _datos[i].$2,
                color: colorScheme.primary,
                width: 20,
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
                final idx = value.toInt();
                if (idx < 0 || idx >= _datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _datos[idx].$1,
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

// ── Gráfico 5: Cancelaciones por profesional (BarChart horizontal, error) ─────

class _GraficoCancelacionesPorProfesional extends StatelessWidget {
  const _GraficoCancelacionesPorProfesional({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  static const List<(String, double)> _datos = [
    ('David L.', 7),
    ('Ana R.', 5),
    ('Carlos M.', 3),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _datos[i].$2,
                color: colorScheme.error,
                width: 20,
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
                final idx = value.toInt();
                if (idx < 0 || idx >= _datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _datos[idx].$1,
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

// ── Gráfico 6: Servicios más solicitados (BarChart horizontal) ────────────────

class _GraficoServiciosMasSolicitados extends StatelessWidget {
  const _GraficoServiciosMasSolicitados({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  static const List<(String, double)> _datos = [
    ('L. Premium', 98),
    ('Exterior', 76),
    ('Interior', 64),
    ('Encerado', 49),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _datos[i].$2,
                color: colorScheme.primary,
                width: 16,
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
                final idx = value.toInt();
                if (idx < 0 || idx >= _datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _datos[idx].$1,
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

// ── Gráfico 7: Facturación por servicio (BarChart) ────────────────────────────

class _GraficoFacturacionPorServicio extends StatelessWidget {
  const _GraficoFacturacionPorServicio({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  static const List<(String, double)> _datos = [
    ('Premium', 5880),
    ('Exterior', 1140),
    ('Interior', 1600),
    ('Encerado', 2450),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_datos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _datos[i].$2,
                color: colorScheme.primary,
                width: 16,
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
                final idx = value.toInt();
                if (idx < 0 || idx >= _datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _datos[idx].$1,
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

// ── Gráfico 8: Cancelaciones por servicio (PieChart donut) ───────────────────

class _GraficoCancelacionesPorServicio extends StatelessWidget {
  const _GraficoCancelacionesPorServicio({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  // TODO: datos reales de API
  // Exterior 4% | Interior 6% | Premium 2% | Encerado 3%
  static const List<(String, double, Color)> _datos = [
    ('Exterior', 4, Colors.blue),
    ('Interior', 6, Colors.purple),
    ('Premium', 2, Colors.green),
    ('Encerado', 3, Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              sections: List.generate(_datos.length, (i) {
                final item = _datos[i];
                // El color de Exterior usa colorScheme.primary
                final color = i == 0 ? colorScheme.primary : item.$3;
                return PieChartSectionData(
                  value: item.$2,
                  color: color,
                  title: '${item.$2}%',
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
        // Leyenda lateral
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_datos.length, (i) {
            final item = _datos[i];
            final color = i == 0 ? colorScheme.primary : item.$3;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _ItemLeyenda(
                color: color,
                etiqueta: item.$1,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── _ItemLeyenda ──────────────────────────────────────────────────────────────

class _ItemLeyenda extends StatelessWidget {
  const _ItemLeyenda({
    required this.color,
    required this.etiqueta,
    required this.textTheme,
    required this.colorScheme,
  });

  final Color color;
  final String etiqueta;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          etiqueta,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }
}