import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: datos reales de API

class _DatosReserva {
  const _DatosReserva({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String cliente;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
}

const List<_DatosReserva> _reservasEjemplo = [
  _DatosReserva(
    id: '1',
    cliente: 'Ana García',
    servicio: 'Lavado exterior',
    empleado: 'Carlos M.',
    hora: '09:00',
    precio: '25,00 €',
    estado: EstadoReserva.confirmada,
  ),
  _DatosReserva(
    id: '2',
    cliente: 'Luis Martín',
    servicio: 'Pulido completo',
    empleado: 'Carlos M.',
    hora: '11:00',
    precio: '80,00 €',
    estado: EstadoReserva.pendiente,
  ),
  _DatosReserva(
    id: '3',
    cliente: 'Marta López',
    servicio: 'Encerado',
    empleado: 'Laura P.',
    hora: '12:00',
    precio: '45,00 €',
    estado: EstadoReserva.pendiente,
  ),
  _DatosReserva(
    id: '4',
    cliente: 'Pedro Ruiz',
    servicio: 'Lavado completo',
    empleado: 'Laura P.',
    hora: '10:00',
    precio: '55,00 €',
    estado: EstadoReserva.cancelada,
  ),
  _DatosReserva(
    id: '5',
    cliente: 'Jorge Díaz',
    servicio: 'Pulido faros',
    empleado: 'Sergio R.',
    hora: '09:30',
    precio: '30,00 €',
    estado: EstadoReserva.completada,
  ),
  _DatosReserva(
    id: '6',
    cliente: 'Sara Gómez',
    servicio: 'Lavado motor',
    empleado: 'Sergio R.',
    hora: '13:00',
    precio: '60,00 €',
    estado: EstadoReserva.confirmada,
  ),
];

// ── Filtros disponibles ───────────────────────────────────────────────────────

enum FiltroReservasAdmin { hoy, semana, pendientes, confirmadas, canceladas }

extension FiltroReservasAdminLabel on FiltroReservasAdmin {
  String get etiqueta {
    switch (this) {
      case FiltroReservasAdmin.hoy:
        return 'Hoy';
      case FiltroReservasAdmin.semana:
        return 'Esta semana';
      case FiltroReservasAdmin.pendientes:
        return 'Pendientes';
      case FiltroReservasAdmin.confirmadas:
        return 'Confirmadas';
      case FiltroReservasAdmin.canceladas:
        return 'Canceladas';
    }
  }
}

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P20 — Lista de reservas del área admin con filtros.
class PantallaAdminReservas extends StatefulWidget {
  const PantallaAdminReservas({
    super.key,
    this.filtroInicial = FiltroReservasAdmin.hoy,
  });

  final FiltroReservasAdmin filtroInicial;

  @override
  State<PantallaAdminReservas> createState() => _PantallaAdminReservasState();
}

class _PantallaAdminReservasState extends State<PantallaAdminReservas> {
  late FiltroReservasAdmin _filtroActivo;

  @override
  void initState() {
    super.initState();
    _filtroActivo = widget.filtroInicial;
  }

  List<_DatosReserva> get _reservasFiltradas {
    // TODO: mover a ViewModel cuando se conecte API.
    // Por ahora el filtro de estado aplica sobre datos hardcodeados;
    // los filtros temporales (hoy/semana) muestran todas las reservas.
    switch (_filtroActivo) {
      case FiltroReservasAdmin.hoy:
      case FiltroReservasAdmin.semana:
        return _reservasEjemplo;
      case FiltroReservasAdmin.pendientes:
        return _reservasEjemplo
            .where((reserva) => reserva.estado == EstadoReserva.pendiente)
            .toList();
      case FiltroReservasAdmin.confirmadas:
        return _reservasEjemplo
            .where((reserva) => reserva.estado == EstadoReserva.confirmada)
            .toList();
      case FiltroReservasAdmin.canceladas:
        return _reservasEjemplo
            .where((reserva) => reserva.estado == EstadoReserva.cancelada)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.reservas,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.add,
        tooltip: 'Nueva reserva',
        heroTag: 'fab-admin-reservas-nueva-reserva',
        onPressed: () => GestorNavegacion.irAAdminSeleccionCliente(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX / 2,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reservas',
                      style: textTheme.displayLarge,
                    ),
                  ),
                  Tooltip(
                    message: 'Filtros',
                    child: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {
                        // TODO: panel de filtros avanzados
                      },
                    ),
                  ),
                  Tooltip(
                    message: 'Nueva reserva',
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          GestorNavegacion.irAAdminSeleccionCliente(context),
                    ),
                  ),
                ],
              ),
            ),

            // ── Chips de filtro ────────────────────────────────────────────
            SizedBox(
              height: 48,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.padX,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                children: FiltroReservasAdmin.values.map((filtro) {
                  final activo = filtro == _filtroActivo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filtro.etiqueta),
                      selected: activo,
                      onSelected: (_) =>
                          setState(() => _filtroActivo = filtro),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Lista de reservas ──────────────────────────────────────────
            Expanded(
              child: _reservasFiltradas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay reservas',
                        style: textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: _reservasFiltradas.length,
                      itemBuilder: (context, index) {
                        final reserva = _reservasFiltradas[index];
                        return TarjetaReservaAdmin(
                          estado: reserva.estado,
                          cliente: reserva.cliente,
                          servicio: reserva.servicio,
                          empleado: reserva.empleado,
                          hora: reserva.hora,
                          precio: reserva.precio,
                          onTap: () => GestorNavegacion.irAAdminDetalleReserva(
                            context,
                            reserva.id,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
