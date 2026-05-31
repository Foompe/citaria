import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_calendario.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';

// Pantalla

/// P26 — Calendario mensual de reservas del área admin.
class PantallaAdminCalendario extends StatefulWidget {
  const PantallaAdminCalendario({super.key});

  @override
  State<PantallaAdminCalendario> createState() =>
      _PantallaAdminCalendarioState();
}

class _PantallaAdminCalendarioState extends State<PantallaAdminCalendario> {
  late final ViewModelAdminCalendario _viewModel;
  int? _diaSeleccionado;

  static const List<String> _cabeceras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const List<String> _nombresMes = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCalendario(
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
    _viewModel.cargarMes(_viewModel.mesActual);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _mesAnterior() {
    setState(() => _diaSeleccionado = null);
    _viewModel.mesAnterior();
  }

  void _mesSiguiente() {
    setState(() => _diaSeleccionado = null);
    _viewModel.mesSiguiente();
  }

  void _seleccionarDia(int dia) {
    setState(() => _diaSeleccionado = _diaSeleccionado == dia ? null : dia);
  }

  (int, int) _infoMes(DateTime mes) {
    final primerDia = DateTime(mes.year, mes.month, 1);
    final diasEnMes = DateTime(mes.year, mes.month + 1, 0).day;
    return (diasEnMes, primerDia.weekday);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminCalendario>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCalendario>(
        builder: (context, vmCalendario, _) {
          final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          final DateTime mes = vmCalendario.mesActual;
          final (diasEnMes, weekdayPrimerDia) = _infoMes(mes);
          final offsetInicio = weekdayPrimerDia - 1;
          final totalCeldas = offsetInicio + diasEnMes;
          final filas = (totalCeldas / 7).ceil();
          final celdasTotales = filas * 7;

          return Scaffold(
            drawer: const MenuLateralAdmin(),
            bottomNavigationBar: const BarraNavegacionAdmin(
              seccionActiva: SeccionAdmin.mas,
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Cabecera
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        espaciado.padX,
                        16,
                        espaciado.padX,
                        0,
                      ),
                      child: Text('Agenda', style: textTheme.displayLarge),
                    ),
                  ),

                  // Selector de mes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: espaciado.padX,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Tooltip(
                            message: 'Mes anterior',
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _mesAnterior,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${_nombresMes[mes.month]} ${mes.year}',
                              style: textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Tooltip(
                            message: 'Mes siguiente',
                            child: IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _mesSiguiente,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cabeceras días semana
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                      child: Row(
                        children: _cabeceras.map((c) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                c,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),

                  // Grid del calendario
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                      child: Stack(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: celdasTotales,
                            itemBuilder: (context, index) {
                              final diaNum = index - offsetInicio + 1;
                              if (index < offsetInicio || diaNum > diasEnMes) {
                                return const SizedBox.shrink();
                              }

                              final nReservas = vmCalendario.contarPorDia(
                                diaNum,
                              );
                              final tieneRes = nReservas > 0;
                              final seleccionado = _diaSeleccionado == diaNum;
                              final hoy = DateTime.now();
                              final esHoy =
                                  hoy.year == mes.year &&
                                  hoy.month == mes.month &&
                                  hoy.day == diaNum;

                              return GestureDetector(
                                onTap: () => _seleccionarDia(diaNum),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: seleccionado
                                        ? colorScheme.primary
                                        : null,
                                    borderRadius: espaciado.radioCard,
                                    border: tieneRes && !seleccionado
                                        ? Border.all(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.4),
                                            width: 1,
                                          )
                                        : esHoy && !seleccionado
                                        ? Border.all(
                                            color: colorScheme.outline
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$diaNum',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: seleccionado
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface,
                                          fontWeight: esHoy
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                      ),
                                      if (tieneRes) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 16,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: seleccionado
                                                ? colorScheme.onPrimary
                                                      .withValues(alpha: 0.25)
                                                : colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$nReservas',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  fontSize: 9,
                                                  color: seleccionado
                                                      ? colorScheme.onPrimary
                                                      : colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (vmCalendario.cargando)
                            Positioned.fill(
                              child: ColoredBox(
                                color: colorScheme.surface,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: Divider(height: 24)),

                  // Panel inferior
                  _PanelInferior(
                    error: vmCalendario.error,
                    onReintentar: vmCalendario.refrescar,
                    diaSeleccionado: _diaSeleccionado,
                    mes: mes.month,
                    reservas: _diaSeleccionado == null
                        ? const []
                        : vmCalendario.reservasPorDia(_diaSeleccionado!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Panel inferior: gestiona carga, error y selección de día

class _PanelInferior extends StatelessWidget {
  const _PanelInferior({
    required this.error,
    required this.onReintentar,
    required this.diaSeleccionado,
    required this.mes,
    required this.reservas,
  });

  final String? error;
  final Future<void> Function() onReintentar;
  final int? diaSeleccionado;
  final int mes;
  final List<DtoReservaCalendario> reservas;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error!,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onReintentar,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (diaSeleccionado == null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Selecciona un día para ver las reservas',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _PanelReservasDia(
      dia: diaSeleccionado!,
      mes: mes,
      reservas: reservas,
    );
  }
}

class _PanelReservasDia extends StatelessWidget {
  const _PanelReservasDia({
    required this.dia,
    required this.mes,
    required this.reservas,
  });

  final int dia;
  final int mes;
  final List<DtoReservaCalendario> reservas;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (reservas.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Sin reservas este día',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: espaciado.padX,
              vertical: 4,
            ),
            child: Text(
              '$dia/${mes.toString().padLeft(2, '0')} — ${reservas.length} reservas',
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            final r = reservas[index];
            return TarjetaReservaAdmin(
              estado: _estadoVisual(r.estado),
              cliente: r.cliente,
              servicio: r.servicio,
              empleado: r.empleado,
              hora: r.hora,
              precio: r.precio,
              onTap: () async {
                final cambiado =
                    await GestorNavegacion.irAAdminDetalleReserva(context, r.id);
                if (cambiado == true && context.mounted) {
                  context.read<ViewModelAdminCalendario>().refrescar();
                }
              },
            );
          },
        ),
      ],
    );
  }
}

chip.EstadoReserva _estadoVisual(datos.EstadoReserva estado) {
  return switch (estado) {
    datos.EstadoReserva.pendiente => chip.EstadoReserva.pendiente,
    datos.EstadoReserva.confirmada => chip.EstadoReserva.confirmada,
    datos.EstadoReserva.cancelada => chip.EstadoReserva.cancelada,
    datos.EstadoReserva.completada => chip.EstadoReserva.completada,
  };
}
