import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: GET /reservas?fecha=X

class _ReservaDia {
  const _ReservaDia({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
    required this.dia,
  });

  final String id;
  final String cliente;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
  final int dia;
}

// Reservas del mes de ejemplo (mayo 2026)
const List<_ReservaDia> _reservasMes = [
  _ReservaDia(
    id: 'r1',
    cliente: 'Ana García',
    servicio: 'Lavado exterior',
    empleado: 'Carlos M.',
    hora: '09:00',
    precio: '25,00 €',
    estado: EstadoReserva.confirmada,
    dia: 3,
  ),
  _ReservaDia(
    id: 'r2',
    cliente: 'Luis Martín',
    servicio: 'Pulido completo',
    empleado: 'Carlos M.',
    hora: '11:00',
    precio: '80,00 €',
    estado: EstadoReserva.pendiente,
    dia: 3,
  ),
  _ReservaDia(
    id: 'r3',
    cliente: 'Marta López',
    servicio: 'Encerado',
    empleado: 'Laura P.',
    hora: '12:00',
    precio: '45,00 €',
    estado: EstadoReserva.pendiente,
    dia: 5,
  ),
  _ReservaDia(
    id: 'r4',
    cliente: 'Pedro Ruiz',
    servicio: 'Lavado completo',
    empleado: 'Laura P.',
    hora: '10:00',
    precio: '55,00 €',
    estado: EstadoReserva.confirmada,
    dia: 5,
  ),
  _ReservaDia(
    id: 'r5',
    cliente: 'Sara Gómez',
    servicio: 'Lavado motor',
    empleado: 'Sergio R.',
    hora: '13:00',
    precio: '60,00 €',
    estado: EstadoReserva.confirmada,
    dia: 7,
  ),
  _ReservaDia(
    id: 'r6',
    cliente: 'Jorge Díaz',
    servicio: 'Pulido faros',
    empleado: 'Sergio R.',
    hora: '09:30',
    precio: '30,00 €',
    estado: EstadoReserva.pendiente,
    dia: 12,
  ),
  _ReservaDia(
    id: 'r7',
    cliente: 'Eva Torres',
    servicio: 'Aspirado interior',
    empleado: 'Carlos M.',
    hora: '14:30',
    precio: '20,00 €',
    estado: EstadoReserva.confirmada,
    dia: 14,
  ),
  _ReservaDia(
    id: 'r8',
    cliente: 'Raúl Sanz',
    servicio: 'Interior completo',
    empleado: 'Sergio R.',
    hora: '15:00',
    precio: '70,00 €',
    estado: EstadoReserva.pendiente,
    dia: 14,
  ),
  _ReservaDia(
    id: 'r9',
    cliente: 'Ana García',
    servicio: 'Encerado',
    empleado: 'Laura P.',
    hora: '10:00',
    precio: '45,00 €',
    estado: EstadoReserva.confirmada,
    dia: 20,
  ),
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P26 — Calendario mensual de reservas del área admin.
class PantallaAdminCalendario extends StatefulWidget {
  const PantallaAdminCalendario({super.key});

  @override
  State<PantallaAdminCalendario> createState() =>
      _PantallaAdminCalendarioState();
}

class _PantallaAdminCalendarioState extends State<PantallaAdminCalendario> {
  DateTime _mesActual = DateTime(2026, 5);
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

  void _mesAnterior() => setState(() {
    _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
    _diaSeleccionado = null;
  });

  void _mesSiguiente() => setState(() {
    _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
    _diaSeleccionado = null;
  });

  int _reservasPorDia(int dia) =>
      _reservasMes.where((r) => r.dia == dia).length;

  List<_ReservaDia> _reservasDelDia(int dia) =>
      _reservasMes.where((r) => r.dia == dia).toList();

  (int, int) _infoMes() {
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    return (diasEnMes, primerDia.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (diasEnMes, weekdayPrimerDia) = _infoMes();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ─────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX,
                0,
              ),
              child: Text('Agenda', style: textTheme.displayLarge),
            ),

            // ── Selector de mes ───────────────────────────────────────────────
            Padding(
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
                      '${_nombresMes[_mesActual.month]} ${_mesActual.year}',
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

            // ── Cabeceras días semana ─────────────────────────────────────────
            Padding(
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
            const SizedBox(height: 4),

            // ── Grid del calendario ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

                  final nReservas = _reservasPorDia(diaNum);
                  final tieneRes = nReservas > 0;
                  final seleccionado = _diaSeleccionado == diaNum;
                  final hoy = DateTime.now();
                  final esHoy =
                      hoy.year == _mesActual.year &&
                      hoy.month == _mesActual.month &&
                      hoy.day == diaNum;

                  return GestureDetector(
                    onTap: () => setState(
                      () => _diaSeleccionado = _diaSeleccionado == diaNum
                          ? null
                          : diaNum,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: seleccionado ? colorScheme.primary : null,
                        borderRadius: espaciado.radioCard,
                        border: tieneRes && !seleccionado
                            ? Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1,
                              )
                            : esHoy && !seleccionado
                            ? Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.5,
                                ),
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
                              fontWeight: esHoy ? FontWeight.bold : null,
                            ),
                          ),
                          if (tieneRes) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 16,
                              height: 14,
                              decoration: BoxDecoration(
                                color: seleccionado
                                    ? colorScheme.onPrimary.withValues(
                                        alpha: 0.25,
                                      )
                                    : colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$nReservas',
                                style: textTheme.labelSmall?.copyWith(
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
            ),

            const Divider(height: 24),

            // ── Panel de reservas del día seleccionado ────────────────────────
            Expanded(
              child: _diaSeleccionado == null
                  ? Center(
                      child: Text(
                        'Selecciona un día para ver las reservas',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _PanelReservasDia(
                      dia: _diaSeleccionado!,
                      mes: _mesActual.month,
                      reservas: _reservasDelDia(_diaSeleccionado!),
                    ),
            ),
          ],
        ),
      ),
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
  final List<_ReservaDia> reservas;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (reservas.isEmpty) {
      return Center(
        child: Text(
          'Sin reservas este día',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        Expanded(
          child: ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final r = reservas[index];
              return TarjetaReservaAdmin(
                estado: r.estado,
                cliente: r.cliente,
                servicio: r.servicio,
                empleado: r.empleado,
                hora: r.hora,
                precio: r.precio,
                onTap: () =>
                    GestorNavegacion.irAAdminDetalleReserva(context, r.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
