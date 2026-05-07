import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: datos reales de API — GET /reservas/:id

class _ReservaDetalle {
  const _ReservaDetalle({
    required this.id,
    required this.estado,
    required this.cliente,
    required this.clienteId,
    required this.telefono,
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.rolEmpleado,
    required this.fecha,
    required this.hora,
    required this.total,
    this.observaciones,
  });

  final String id;
  final EstadoReserva estado;
  final String cliente;
  final String clienteId;
  final String telefono;
  final String servicio;
  final String duracion;
  final String empleado;
  final String rolEmpleado;
  final String fecha;
  final String hora;
  final String total;
  final String? observaciones;
}

const _ReservaDetalle _reservaEjemplo = _ReservaDetalle(
  id: '1',
  estado: EstadoReserva.pendiente,
  cliente: 'Ana García',
  clienteId: 'c1',
  telefono: '+34 612 345 678',
  servicio: 'Lavado exterior premium',
  duracion: '45 min',
  empleado: 'Carlos Martínez',
  rolEmpleado: 'Especialista',
  fecha: 'Lun 3 may 2026',
  hora: '09:00',
  total: '25,00 €',
  observaciones: 'El cliente pide que se evite el interior del maletero.',
);

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P21 — Detalle de una reserva en el área admin.
///
/// Ruta: /admin/reservas/:id  — arguments: {'id': String}
class PantallaAdminDetalleReserva extends StatefulWidget {
  const PantallaAdminDetalleReserva({super.key});

  @override
  State<PantallaAdminDetalleReserva> createState() =>
      _PantallaAdminDetalleReservaState();
}

class _PantallaAdminDetalleReservaState
    extends State<PantallaAdminDetalleReserva> {
  // TODO: datos reales de API — GET /reservas/:id
  // Estado local editable mientras no hay ViewModel
  EstadoReserva _estado = _reservaEjemplo.estado;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Reserva',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Opciones',
          child: IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // TODO: menú de opciones
            },
          ),
        ),
      ),
      bottomNavigationBar: BarraCtaFija(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (_estado == EstadoReserva.pendiente) ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: PATCH /reservas/:id/estado → confirmada
                        setState(() => _estado = EstadoReserva.confirmada);
                      },
                      child: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                    onPressed: () {
                      // TODO: PATCH /reservas/:id/estado → cancelada
                      setState(() => _estado = EstadoReserva.cancelada);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
              onPressed: () {
                // TODO: DELETE /reservas/:id
              },
              child: const Text('Eliminar reserva'),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX,
          16,
          espaciado.padX,
          24,
        ),
        children: [
          // Card estado
          _CardEstado(
            estado: _estado,
            colorScheme: colorScheme,
            textTheme: textTheme,
            espaciado: espaciado,
            onCambiarEstado: (nuevo) => setState(() => _estado = nuevo),
          ),
          const SizedBox(height: 12),

          // Card cliente
          _CardCliente(
            nombre: _reservaEjemplo.cliente,
            telefono: _reservaEjemplo.telefono,
            clienteId: _reservaEjemplo.clienteId,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),

          // Card servicio + empleado
          _CardServicioEmpleado(
            servicio: _reservaEjemplo.servicio,
            duracion: _reservaEjemplo.duracion,
            empleado: _reservaEjemplo.empleado,
            rol: _reservaEjemplo.rolEmpleado,
            colorScheme: colorScheme,
            textTheme: textTheme,
            espaciado: espaciado,
          ),
          const SizedBox(height: 12),

          // Card fecha + total
          _CardFechaTotal(
            fecha: _reservaEjemplo.fecha,
            hora: _reservaEjemplo.hora,
            total: _reservaEjemplo.total,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          // Card observaciones (condicional)
          if (_reservaEjemplo.observaciones != null) ...[
            const SizedBox(height: 12),
            _CardObservaciones(
              texto: _reservaEjemplo.observaciones!,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ── Subwidgets ─────────────────────────────────────────────────────────────────

class _CardEstado extends StatelessWidget {
  const _CardEstado({
    required this.estado,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
    required this.onCambiarEstado,
  });

  final EstadoReserva estado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;
  final ValueChanged<EstadoReserva> onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ChipEstado(estado: estado),
            const Spacer(),
            DropdownButton<EstadoReserva>(
              value: estado,
              underline: const SizedBox.shrink(),
              onChanged: (v) {
                if (v != null) onCambiarEstado(v);
                // TODO: PATCH /reservas/:id/estado
              },
              items: EstadoReserva.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: ChipEstado(estado: e),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCliente extends StatelessWidget {
  const _CardCliente({
    required this.nombre,
    required this.telefono,
    required this.clienteId,
    required this.colorScheme,
    required this.textTheme,
  });

  final String nombre;
  final String telefono;
  final String clienteId;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String get _iniciales {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLIENTE',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _iniciales,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: textTheme.displaySmall),
                      Text(
                        telefono,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: OutlinedButton(
                    onPressed: () =>
                        GestorNavegacion.irAAdminDetalleCliente(context, clienteId),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Ver ficha'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardServicioEmpleado extends StatelessWidget {
  const _CardServicioEmpleado({
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.rol,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final String servicio;
  final String duracion;
  final String empleado;
  final String rol;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SERVICIO + EMPLEADO',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: reasignar servicio/empleado
                  },
                  child: const Text('Reasignar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(servicio, style: textTheme.bodyLarge),
                ),
                Text(
                  duracion,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    empleado.isNotEmpty ? empleado[0].toUpperCase() : '?',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(empleado, style: textTheme.bodyLarge),
                ),
                Text(
                  rol,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFechaTotal extends StatelessWidget {
  const _CardFechaTotal({
    required this.fecha,
    required this.hora,
    required this.total,
    required this.colorScheme,
    required this.textTheme,
  });

  final String fecha;
  final String hora;
  final String total;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  '$fecha  ·  $hora',
                  style: textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: textTheme.bodyLarge),
                Text(
                  total,
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardObservaciones extends StatelessWidget {
  const _CardObservaciones({
    required this.texto,
    required this.colorScheme,
    required this.textTheme,
  });

  final String texto;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OBSERVACIONES',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(texto, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}