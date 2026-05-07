import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

// ── Modelos de datos hardcodeados ─────────────────────────────────────────────
// TODO: cargar empleados y reservas del día desde API

class _Empleado {
  const _Empleado({
    required this.id,
    required this.nombre,
    this.avatarAsset,
    this.avatarUrl,
  });

  final String id;
  final String nombre;
  final String? avatarAsset;
  final String? avatarUrl;
}

class _ReservaCalendario {
  const _ReservaCalendario({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.horaInicioH,
    required this.horaInicioM,
    required this.duracionMin,
    required this.empleadoId,
    required this.estado,
  });

  final String id;
  final String cliente;
  final String servicio;
  final int horaInicioH;
  final int horaInicioM;
  final int duracionMin;
  final String empleadoId;
  final EstadoReserva estado;
}

const List<_Empleado> _empleados = [
  _Empleado(id: 'emp-1', nombre: 'Carlos M.'),
  _Empleado(id: 'emp-2', nombre: 'Laura P.'),
  _Empleado(id: 'emp-3', nombre: 'Sergio R.'),
  _Empleado(id: 'emp-4', nombre: 'Nuria V.'), // TODO: cargar de API
  _Empleado(id: 'emp-5', nombre: 'Diego F.'), // TODO: cargar de API
  _Empleado(id: 'emp-6', nombre: 'Isabel C.'), // TODO: cargar de API
];

const List<_ReservaCalendario> _reservas = [
  _ReservaCalendario(
    id: 'r1',
    cliente: 'Ana García',
    servicio: 'Lavado exterior',
    horaInicioH: 9,
    horaInicioM: 0,
    duracionMin: 45,
    empleadoId: 'emp-1',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r2',
    cliente: 'Luis Martín',
    servicio: 'Pulido completo',
    horaInicioH: 11,
    horaInicioM: 0,
    duracionMin: 90,
    empleadoId: 'emp-1',
    estado: EstadoReserva.pendiente,
  ),
  _ReservaCalendario(
    id: 'r3',
    cliente: 'Eva Torres',
    servicio: 'Aspirado interior',
    horaInicioH: 14,
    horaInicioM: 30,
    duracionMin: 60,
    empleadoId: 'emp-1',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r4',
    cliente: 'Pedro Ruiz',
    servicio: 'Lavado completo',
    horaInicioH: 10,
    horaInicioM: 0,
    duracionMin: 60,
    empleadoId: 'emp-2',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r5',
    cliente: 'Marta López',
    servicio: 'Encerado',
    horaInicioH: 12,
    horaInicioM: 0,
    duracionMin: 45,
    empleadoId: 'emp-2',
    estado: EstadoReserva.pendiente,
  ),
  _ReservaCalendario(
    id: 'r6',
    cliente: 'Jorge Díaz',
    servicio: 'Pulido faros',
    horaInicioH: 9,
    horaInicioM: 30,
    duracionMin: 30,
    empleadoId: 'emp-3',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r7',
    cliente: 'Sara Gómez',
    servicio: 'Lavado motor',
    horaInicioH: 13,
    horaInicioM: 0,
    duracionMin: 75,
    empleadoId: 'emp-3',
    estado: EstadoReserva.pendiente,
  ),
  _ReservaCalendario(
    id: 'r8',
    cliente: 'Raúl Sanz',
    servicio: 'Interior completo',
    horaInicioH: 15,
    horaInicioM: 0,
    duracionMin: 90,
    empleadoId: 'emp-3',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r9',
    cliente: 'Carmen Vidal',
    servicio: 'Lavado exterior',
    horaInicioH: 9,
    horaInicioM: 0,
    duracionMin: 45,
    empleadoId: 'emp-4',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r10',
    cliente: 'Tomás Herrera',
    servicio: 'Pulido completo',
    horaInicioH: 11,
    horaInicioM: 30,
    duracionMin: 90,
    empleadoId: 'emp-4',
    estado: EstadoReserva.pendiente,
  ),
  _ReservaCalendario(
    id: 'r11',
    cliente: 'Elena Moreno',
    servicio: 'Encerado',
    horaInicioH: 15,
    horaInicioM: 0,
    duracionMin: 20,
    empleadoId: 'emp-4',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r12',
    cliente: 'Álvaro Pons',
    servicio: 'Aspirado interior',
    horaInicioH: 10,
    horaInicioM: 0,
    duracionMin: 30,
    empleadoId: 'emp-5',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r13',
    cliente: 'Rosa Cano',
    servicio: 'Lavado completo',
    horaInicioH: 12,
    horaInicioM: 30,
    duracionMin: 60,
    empleadoId: 'emp-5',
    estado: EstadoReserva.pendiente,
  ),
  _ReservaCalendario(
    id: 'r14',
    cliente: 'Iván Blanco',
    servicio: 'Pulido faros',
    horaInicioH: 16,
    horaInicioM: 0,
    duracionMin: 45,
    empleadoId: 'emp-5',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r15',
    cliente: 'Lucía Prieto',
    servicio: 'Lavado motor',
    horaInicioH: 9,
    horaInicioM: 30,
    duracionMin: 75,
    empleadoId: 'emp-6',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCalendario(
    id: 'r16',
    cliente: 'Mario Fuentes',
    servicio: 'Interior completo',
    horaInicioH: 13,
    horaInicioM: 0,
    duracionMin: 90,
    empleadoId: 'emp-6',
    estado: EstadoReserva.pendiente,
  ),
];

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
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _scrollHoras = ScrollController();
    _scrollGrid = ScrollController();
    _scrollHorizontal = ScrollController();
    _scrollHoras.addListener(_sincronizarDesdeHoras);
    _scrollGrid.addListener(_sincronizarDesdeGrid);
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
    super.dispose();
  }

  String _fechaHoy() {
    const diasSemana = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const meses = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final hoy = DateTime.now();
    return '${diasSemana[hoy.weekday]} ${hoy.day} ${meses[hoy.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final double anchoGrid = _empleados.length * _anchoCeldaEmpleado;
    final double alturaGrid = _nFranjas * _alturaFranja;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.inicio,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.add,
        tooltip: 'Nueva reserva',
        heroTag: 'fab-admin-nueva-reserva',
        onPressed: () => GestorNavegacion.irAAdminSeleccionCliente(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _CabeceraInicio(
              fecha: _fechaHoy(),
              espaciado: espaciado,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            Expanded(
              child: Row(
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
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final String fecha;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

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
            child: Center(child: Text(fecha, style: textTheme.displaySmall)),
          ),
          _BotonNotificacionesPendientes(
            pendientes: 3,
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
                    borderRadius: BorderRadius.circular(999),
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
  const _FilaEmpleados({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _alturaFilaEmpleado,
      child: Row(
        children: _empleados.map((empleado) {
          return SizedBox(
            width: _anchoCeldaEmpleado,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarFallbackCitaria(
                  texto: empleado.nombre,
                  imagenAsset: empleado.avatarAsset,
                  imagenUrl: empleado.avatarUrl,
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
    required this.colorScheme,
    required this.textTheme,
    required this.anchoGrid,
    required this.alturaGrid,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double anchoGrid;
  final double alturaGrid;

  int _indiceEmpleado(String empleadoId) {
    return _empleados.indexWhere((empleado) => empleado.id == empleadoId);
  }

  @override
  Widget build(BuildContext context) {
    final estados = Theme.of(context).extension<EstadosReservaCitaria>()!;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    final reservasVisibles = _reservas.where((reserva) {
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
        ...List.generate(_empleados.length - 1, (i) {
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
                  reserva.id,
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
