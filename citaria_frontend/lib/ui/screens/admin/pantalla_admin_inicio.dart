import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_inicio.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:provider/provider.dart';

// ── Constantes de layout ───────────────────────────────────────────────────────
const double _anchoCeldaEmpleado = 120.0;
const double _alturaFranja = 80.0;
const double _alturaSubfranja = _alturaFranja / 4;
const double _anchoHoras = 52.0;
const double _alturaFilaEmpleado = 80.0;
const int _horaInicio = 9;
const int _horaFin = 20;
const int _nFranjas = _horaFin - _horaInicio;

// ── Pantalla ───────────────────────────────────────────────────────────────────

/// P19 — Pantalla de inicio del área admin.
///
/// Muestra un calendario tipo agenda con eje X (empleados) y
/// eje Y (franjas horarias). El scroll vertical está sincronizado
/// entre la columna de horas fija y el grid de reservas mediante
/// dos ScrollControllers independientes con listener de sincronía.
class PantallaAdminInicio extends StatefulWidget {
  const PantallaAdminInicio({super.key});

  @override
  State<PantallaAdminInicio> createState() => _PantallaAdminInicioState();
}

class _PantallaAdminInicioState extends State<PantallaAdminInicio> {
  late final ScrollController _scrollHoras;
  late final ScrollController _scrollGrid;
  late final ScrollController _scrollHorizontal;
  late final ViewModelAdminInicio _viewModel;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _scrollHoras = ScrollController();
    _scrollGrid = ScrollController();
    _scrollHorizontal = ScrollController();
    _scrollHoras.addListener(_sincronizarDesdeHoras);
    _scrollGrid.addListener(_sincronizarDesdeGrid);
    _viewModel = ViewModelAdminInicio(
      repoEmpleados: context.read<RepoEmpleados>(),
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarInicio();
  }

  void _sincronizarDesdeHoras() {
    if (_sincronizando) return;
    _sincronizando = true;
    if (_scrollGrid.hasClients) {
      _scrollGrid.jumpTo(_scrollHoras.offset);
    }
    _sincronizando = false;
  }

  void _sincronizarDesdeGrid() {
    if (_sincronizando) return;
    _sincronizando = true;
    if (_scrollHoras.hasClients) {
      _scrollHoras.jumpTo(_scrollGrid.offset);
    }
    _sincronizando = false;
  }

  @override
  void dispose() {
    _scrollHoras.removeListener(_sincronizarDesdeHoras);
    _scrollGrid.removeListener(_sincronizarDesdeGrid);
    _scrollHoras.dispose();
    _scrollGrid.dispose();
    _scrollHorizontal.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _mostrarSelectorFecha(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => _SelectorFechaDia(
        fechaSeleccionada: _viewModel.fechaSeleccionada,
        onFechaSeleccionada: (fecha) {
          Navigator.pop(ctx);
          _viewModel.cambiarFecha(fecha);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider<ViewModelAdminInicio>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminInicio>(
        builder: (context, vmInicio, _) {
          final List<DtoEmpleadoInicioAdmin> empleados = vmInicio.empleados;
          final List<DtoReservaInicioAdmin> reservas = vmInicio.reservas;
          final int totalColumnas = empleados.isEmpty ? 1 : empleados.length;
          final double anchoGrid = totalColumnas * _anchoCeldaEmpleado;
          const double alturaGrid = _nFranjas * _alturaFranja;

          return Scaffold(
            drawer: const MenuLateralAdmin(),
            bottomNavigationBar: const BarraNavegacionAdmin(
              seccionActiva: SeccionAdmin.inicio,
            ),
            floatingActionButton: FabCitaria(
              icono: Icons.add,
              tooltip: 'Nueva reserva',
              heroTag: 'fab-admin-nueva-reserva',
              onPressed: () =>
                  GestorNavegacion.irAAdminSeleccionCliente(context),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _CabeceraInicio(
                    fecha: vmInicio.fechaSeleccionada,
                    onFechaTap: () => _mostrarSelectorFecha(context),
                    pendientes: vmInicio.reservasPendientes,
                    espaciado: espaciado,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  Expanded(
                    child: _ContenidoInicio(
                      vmInicio: vmInicio,
                      empleados: empleados,
                      agenda: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: _anchoHoras,
                            child: Column(
                              children: [
                                const SizedBox(height: _alturaFilaEmpleado),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollHoras,
                                    child: _ColumnaHoras(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollHorizontal,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: anchoGrid,
                                child: Column(
                                  children: [
                                    _FilaEmpleados(
                                      empleados: empleados,
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        controller: _scrollGrid,
                                        child: SizedBox(
                                          width: anchoGrid,
                                          height: alturaGrid,
                                          child: _GridReservas(
                                            empleados: empleados,
                                            reservas: reservas,
                                            colorScheme: colorScheme,
                                            textTheme: textTheme,
                                            anchoGrid: anchoGrid,
                                            alturaGrid: alturaGrid,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _ContenidoInicio extends StatelessWidget {
  const _ContenidoInicio({
    required this.vmInicio,
    required this.empleados,
    required this.agenda,
  });

  final ViewModelAdminInicio vmInicio;
  final List<DtoEmpleadoInicioAdmin> empleados;
  final Widget agenda;

  @override
  Widget build(BuildContext context) {
    if (vmInicio.cargando && empleados.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmInicio.error;
    if (error != null && empleados.isEmpty) {
      return _EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmInicio.refrescar,
      );
    }

    if (empleados.isEmpty) {
      return _EstadoCentrado(
        mensaje: 'No hay empleados activos para mostrar la agenda.',
        accionTexto: 'Refrescar',
        onAccion: vmInicio.refrescar,
      );
    }

    return Stack(
      children: [
        agenda,
        if (vmInicio.cargando)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (error != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Material(
              borderRadius: Theme.of(context).extension<EspaciadoCitaria>()!.radioInput,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EstadoCentrado extends StatelessWidget {
  const _EstadoCentrado({
    required this.mensaje,
    required this.accionTexto,
    required this.onAccion,
  });

  final String mensaje;
  final String accionTexto;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAccion, child: Text(accionTexto)),
          ],
        ),
      ),
    );
  }
}

// ── Cabecera personalizada ─────────────────────────────────────────────────────

class _CabeceraInicio extends StatelessWidget {
  const _CabeceraInicio({
    required this.fecha,
    required this.onFechaTap,
    required this.pendientes,
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final DateTime fecha;
  final VoidCallback onFechaTap;
  final int pendientes;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String _formatearFecha(DateTime d) {
    const dias = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final hoy = DateTime.now();
    final sufijo = d.year != hoy.year ? ' ${d.year}' : '';
    return '${dias[d.weekday]} ${d.day} ${meses[d.month]}$sufijo';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.padX / 2,
        vertical: 4,
      ),
      child: Row(
        children: [
          Tooltip(
            message: 'Menú',
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: onFechaTap,
                borderRadius: espaciado.radioPill,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatearFecha(fecha),
                        style: textTheme.displaySmall,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.unfold_more,
                        size: 18,
                        color: colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _BotonNotificacionesPendientes(
            pendientes: pendientes,
            onPressed: () =>
                GestorNavegacion.irAAdminReservasPendientes(context),
          ),
        ],
      ),
    );
  }
}

class _BotonNotificacionesPendientes extends StatelessWidget {
  const _BotonNotificacionesPendientes({
    required this.pendientes,
    required this.onPressed,
  });

  final int pendientes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mostrarBadge = pendientes > 0;

    return Tooltip(
      message: 'Reservas pendientes',
      child: IconButton(
        onPressed: onPressed,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            if (mostrarBadge)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: Theme.of(context).extension<EspaciadoCitaria>()!.radioPill,
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pendientes > 9 ? '9+' : pendientes.toString(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onError,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Columna de horas ───────────────────────────────────────────────────────────

class _ColumnaHoras extends StatelessWidget {
  const _ColumnaHoras({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _nFranjas * _alturaFranja,
      child: Column(
        children: [
          for (int i = 0; i < _nFranjas; i++)
            SizedBox(
              height: _alturaFranja,
              width: _anchoHoras,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '${(_horaInicio + i).toString().padLeft(2, '0')}:00',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 10,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fila de empleados ──────────────────────────────────────────────────────────

class _FilaEmpleados extends StatelessWidget {
  const _FilaEmpleados({
    required this.empleados,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<DtoEmpleadoInicioAdmin> empleados;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _alturaFilaEmpleado,
      child: Row(
        children: empleados.map((empleado) {
          return SizedBox(
            width: _anchoCeldaEmpleado,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarFallbackCitaria(
                  texto: empleado.nombre,
                  imagenUrl: empleado.fotoUrl,
                  tamano: 38,
                  radio: 19,
                ),
                const SizedBox(height: 4),
                Text(
                  empleado.nombre,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Grid de reservas ───────────────────────────────────────────────────────────

class _GridReservas extends StatelessWidget {
  const _GridReservas({
    required this.empleados,
    required this.reservas,
    required this.colorScheme,
    required this.textTheme,
    required this.anchoGrid,
    required this.alturaGrid,
  });

  final List<DtoEmpleadoInicioAdmin> empleados;
  final List<DtoReservaInicioAdmin> reservas;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double anchoGrid;
  final double alturaGrid;

  int _indiceEmpleado(int empleadoId) {
    return empleados.indexWhere((empleado) => empleado.id == empleadoId);
  }

  @override
  Widget build(BuildContext context) {
    final estados = Theme.of(context).extension<EstadosReservaCitaria>()!;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    final reservasVisibles = reservas.where((reserva) {
      final estadoVisible =
          reserva.estado == EstadoReserva.pendiente ||
          reserva.estado == EstadoReserva.confirmada;
      return estadoVisible && _indiceEmpleado(reserva.empleadoId) != -1;
    });

    return Stack(
      children: [
        ...List.generate(_nFranjas * 4 + 1, (i) {
          final esHoraCompleta = i % 4 == 0;

          return Positioned(
            top: i * _alturaSubfranja,
            left: 0,
            right: 0,
            child: Divider(
              height: 1,
              thickness: esHoraCompleta ? 0.8 : 0.4,
              color: colorScheme.outlineVariant.withValues(
                alpha: esHoraCompleta ? 0.75 : 0.35,
              ),
            ),
          );
        }),
        ...List.generate(empleados.length - 1, (i) {
          return Positioned(
            top: 0,
            bottom: 0,
            left: (i + 1) * _anchoCeldaEmpleado,
            child: VerticalDivider(
              width: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          );
        }),
        ...reservasVisibles.map((reserva) {
          final indiceEmpleado = _indiceEmpleado(reserva.empleadoId);
          final colores = reserva.estado == EstadoReserva.pendiente
              ? estados.pendiente
              : estados.confirmada;

          const double minAPx = _alturaFranja / 60.0;
          final top =
              (reserva.horaInicioH - _horaInicio) * _alturaFranja +
              reserva.horaInicioM * minAPx;
          final left = indiceEmpleado * _anchoCeldaEmpleado + 4;
          final horaFin =
              reserva.horaInicioH * 60 +
              reserva.horaInicioM +
              reserva.duracionMin;
          final hFin = horaFin ~/ 60;
          final mFin = horaFin % 60;
          final horaTexto =
              '${reserva.horaInicioH.toString().padLeft(2, '0')}:'
              '${reserva.horaInicioM.toString().padLeft(2, '0')} - '
              '${hFin.toString().padLeft(2, '0')}:'
              '${mFin.toString().padLeft(2, '0')}';

          final double alturaBloque = reserva.duracionMin * minAPx;
          final Widget contenido;

          if (reserva.duracionMin >= 55) {
            contenido = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horaTexto,
                  style: textTheme.bodySmall?.copyWith(
                    color: colores.texto,
                    fontSize: 9,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  reserva.cliente,
                  style: textTheme.labelSmall?.copyWith(
                    color: colores.texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reserva.servicio,
                  style: textTheme.bodySmall?.copyWith(
                    color: colores.texto,
                    fontSize: 9,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          } else if (reserva.duracionMin >= 32) {
            contenido = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horaTexto,
                  style: textTheme.bodySmall?.copyWith(
                    color: colores.texto,
                    fontSize: 9,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  reserva.cliente,
                  style: textTheme.labelSmall?.copyWith(
                    color: colores.texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          } else {
            contenido = Text(
              reserva.cliente,
              style: textTheme.labelSmall?.copyWith(
                color: colores.texto,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }

          return Positioned(
            top: top,
            left: left,
            width: _anchoCeldaEmpleado - 8,
            height: alturaBloque,
            child: Material(
              color: Colors.transparent,
              borderRadius: espaciado.radioInput,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                borderRadius: espaciado.radioInput,
                onTap: () => GestorNavegacion.irAAdminDetalleReserva(
                  context,
                  reserva.id.toString(),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: colores.fondo,
                    borderRadius: espaciado.radioInput,
                    border: Border.all(
                      color: colores.texto.withValues(alpha: 0.34),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: contenido,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Selector de fecha ──────────────────────────────────────────────────────────

class _SelectorFechaDia extends StatefulWidget {
  const _SelectorFechaDia({
    required this.fechaSeleccionada,
    required this.onFechaSeleccionada,
  });

  final DateTime fechaSeleccionada;
  final void Function(DateTime) onFechaSeleccionada;

  @override
  State<_SelectorFechaDia> createState() => _SelectorFechaDiaState();
}

class _SelectorFechaDiaState extends State<_SelectorFechaDia> {
  static const int _diasAtras = 60;
  static const int _diasAdelante = 60;
  static const double _alturaItem = 52.0;

  late final List<DateTime> _dias;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    final base = DateTime(hoy.year, hoy.month, hoy.day);
    _dias = List.generate(
      _diasAtras + _diasAdelante + 1,
      (i) {
        final n = i - _diasAtras;
        final d = DateTime(base.year, base.month, base.day + n);
        return DateTime(d.year, d.month, d.day);
      },
    );
    final int idx = _dias.indexWhere(
      (d) =>
          d.year == widget.fechaSeleccionada.year &&
          d.month == widget.fechaSeleccionada.month &&
          d.day == widget.fechaSeleccionada.day,
    );
    final double offset = idx > 2 ? (idx - 2) * _alturaItem : 0.0;
    _scroll = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hoy = DateTime.now();
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Seleccionar día', style: textTheme.displaySmall),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _alturaItem * 7,
          child: ListView.builder(
            controller: _scroll,
            itemCount: _dias.length,
            itemExtent: _alturaItem,
            itemBuilder: (ctx, i) {
              final dia = _dias[i];
              final esSeleccionado =
                  dia.year == widget.fechaSeleccionada.year &&
                  dia.month == widget.fechaSeleccionada.month &&
                  dia.day == widget.fechaSeleccionada.day;
              final esHoy =
                  dia.year == hoySolo.year &&
                  dia.month == hoySolo.month &&
                  dia.day == hoySolo.day;
              return _ItemDia(
                fecha: dia,
                esSeleccionado: esSeleccionado,
                esHoy: esHoy,
                onTap: () => widget.onFechaSeleccionada(dia),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ItemDia extends StatelessWidget {
  const _ItemDia({
    required this.fecha,
    required this.esSeleccionado,
    required this.esHoy,
    required this.onTap,
  });

  final DateTime fecha;
  final bool esSeleccionado;
  final bool esHoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    const diasSemana = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];

    final colorTexto =
        esSeleccionado ? colorScheme.primary : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: esSeleccionado ? colorScheme.primaryContainer : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  diasSemana[fecha.weekday],
                  style: textTheme.bodySmall?.copyWith(color: colorTexto),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  fecha.day.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorTexto,
                    fontWeight:
                        esSeleccionado ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  meses[fecha.month],
                  style: textTheme.bodySmall?.copyWith(color: colorTexto),
                ),
              ),
              if (esHoy)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: espaciado.radioPill,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'hoy',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
