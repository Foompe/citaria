import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: GET /clientes/:id

class _ClienteDetalle {
  const _ClienteDetalle({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.dni,
    required this.email,
    required this.telefono,
    this.notas,
  });

  final String id;
  final String nombre;
  final String apellidos;
  final String dni;
  final String email;
  final String telefono;
  final String? notas;
}

const _ClienteDetalle _clienteEjemplo = _ClienteDetalle(
  id: 'c1',
  nombre: 'Ana',
  apellidos: 'García López',
  dni: '12345678A',
  email: 'ana.garcia@email.com',
  telefono: '+34 612 345 678',
  notas: 'Cliente habitual. Prefiere cita por las mañanas.',
);

class _ReservaCliente {
  const _ReservaCliente({
    required this.id,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
}

// TODO: GET /clientes/:id/reservas
const List<_ReservaCliente> _reservasCliente = [
  _ReservaCliente(
    id: 'r1',
    servicio: 'Lavado exterior',
    empleado: 'Carlos M.',
    hora: '09:00',
    precio: '25,00 €',
    estado: EstadoReserva.confirmada,
  ),
  _ReservaCliente(
    id: 'r2',
    servicio: 'Pulido completo',
    empleado: 'Laura P.',
    hora: '11:00',
    precio: '80,00 €',
    estado: EstadoReserva.completada,
  ),
  _ReservaCliente(
    id: 'r3',
    servicio: 'Aspirado interior',
    empleado: 'Carlos M.',
    hora: '14:30',
    precio: '20,00 €',
    estado: EstadoReserva.cancelada,
  ),
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P25 — Ficha de cliente en el área admin.
///
/// Ruta: /admin/clientes/:id  — arguments: {'id': String}
class PantallaAdminDetalleCliente extends StatefulWidget {
  const PantallaAdminDetalleCliente({super.key});

  @override
  State<PantallaAdminDetalleCliente> createState() =>
      _PantallaAdminDetalleClienteState();
}

class _PantallaAdminDetalleClienteState
    extends State<PantallaAdminDetalleCliente>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _nombreCompleto =>
      '${_clienteEjemplo.nombre} ${_clienteEjemplo.apellidos}';

  String get _iniciales {
    final n = _clienteEjemplo.nombre;
    final a = _clienteEjemplo.apellidos;
    return '${n.isNotEmpty ? n[0] : ''}${a.isNotEmpty ? a[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Cliente',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Editar',
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: edición inline del cliente
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Cabecera perfil centrada ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _iniciales,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _nombreCompleto,
                  style: textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _clienteEjemplo.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // ── TabBar ────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Datos'),
              Tab(text: 'Reservas'),
            ],
          ),

          // ── TabBarView ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Datos
                _TabDatos(
                  cliente: _clienteEjemplo,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                // Tab Reservas
                _TabReservas(
                  reservas: _reservasCliente,
                  clienteNombre: _nombreCompleto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Datos ─────────────────────────────────────────────────────────────────

class _TabDatos extends StatelessWidget {
  const _TabDatos({
    required this.cliente,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final _ClienteDetalle cliente;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    final campos = [
      (Icons.person_outline,       'Nombre',    cliente.nombre),
      (Icons.badge_outlined,       'DNI',       cliente.dni),
      (Icons.email_outlined,       'Email',     cliente.email),
      (Icons.phone_outlined,       'Teléfono',  cliente.telefono),
      if (cliente.notas != null)
        (Icons.notes_outlined,     'Notas',     cliente.notas!),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(
        espaciado.padX,
        16,
        espaciado.padX,
        24,
      ),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: Column(
            children: [
              for (int i = 0; i < campos.length; i++) ...[
                ListTile(
                  leading: Icon(campos[i].$1, color: colorScheme.outline),
                  title: Text(
                    campos[i].$2,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  subtitle: Text(
                    campos[i].$3,
                    style: textTheme.bodyLarge,
                  ),
                ),
                if (i < campos.length - 1)
                  Divider(
                    height: 1,
                    indent: espaciado.padX,
                    endIndent: espaciado.padX,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          onPressed: () {
            // TODO: DELETE /clientes/:id
          },
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }
}

// ── Tab Reservas ──────────────────────────────────────────────────────────────

class _TabReservas extends StatelessWidget {
  const _TabReservas({
    required this.reservas,
    required this.clienteNombre,
  });

  final List<_ReservaCliente> reservas;
  final String clienteNombre;

  @override
  Widget build(BuildContext context) {
    if (reservas.isEmpty) {
      return Center(
        child: Text(
          'Sin reservas',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        final r = reservas[index];
        return TarjetaReservaAdmin(
          estado: r.estado,
          cliente: clienteNombre,
          servicio: r.servicio,
          empleado: r.empleado,
          hora: r.hora,
          precio: r.precio,
          onTap: () =>
              GestorNavegacion.irAAdminDetalleReserva(context, r.id),
        );
      },
    );
  }
}