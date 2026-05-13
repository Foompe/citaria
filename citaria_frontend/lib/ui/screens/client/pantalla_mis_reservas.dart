import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

/// Pantalla de reservas del cliente (P09).
///
/// Tabs "Próximas" / "Pasadas" con listado de tarjetas de reserva.
///
/// HARDCODING TEMPORAL:
///   - Reservas próximas: 2 items fijos → TODO: cargar de API
///   - Reservas pasadas: 2 items fijos → TODO: cargar de API
class PantallaMisReservas extends StatelessWidget {
  const PantallaMisReservas({super.key});

  // TODO: cargar reservas de API
  static const List<Map<String, dynamic>> _proximas = [
    {
      'id': 'r1',
      'estado': EstadoReserva.confirmada,
      'nombre': 'Lavado exterior',
      'meta': 'Lunes 5 may · 10:00 h',
      'precio': '15 €',
    },
    {
      'id': 'r2',
      'estado': EstadoReserva.pendiente,
      'nombre': 'Pulido completo',
      'meta': 'Miércoles 7 may · 16:00 h',
      'precio': '80 €',
    },
  ];

  // TODO: cargar reservas de API
  static const List<Map<String, dynamic>> _pasadas = [
    {
      'id': 'r3',
      'estado': EstadoReserva.completada,
      'nombre': 'Interior premium',
      'meta': 'Viernes 25 abr · 11:00 h',
      'precio': '45 €',
    },
    {
      'id': 'r4',
      'estado': EstadoReserva.cancelada,
      'nombre': 'Detailing completo',
      'meta': 'Martes 15 abr · 09:00 h',
      'precio': '150 €',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const BarraNavegacionCliente(
          seccionActiva: SeccionCliente.reservas,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera manual ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  16,
                  espaciado.padX,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Mis reservas',
                        style: textTheme.displayLarge,
                      ),
                    ),
                    Semantics(
                      label: 'Nueva reserva',
                      child: IconButton(
                        tooltip: 'Nueva reserva',
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            GestorNavegacion.irAWizardServicios(context),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Tabs ───────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: espaciado.padX,
                  right: espaciado.padX,
                  top: 16,
                ),
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Próximas'),
                    Tab(text: 'Pasadas'),
                  ],
                ),
              ),
              // ── Contenido tabs ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    _ListaReservas(
                      reservas: _proximas,
                      mensajeVacio: 'No tienes próximas reservas.',
                    ),
                    _ListaReservas(
                      reservas: _pasadas,
                      mensajeVacio: 'No tienes reservas pasadas.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _ListaReservas extends StatelessWidget {
  const _ListaReservas({
    required this.reservas,
    required this.mensajeVacio,
  });

  final List<Map<String, dynamic>> reservas;
  final String mensajeVacio;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (reservas.isEmpty) {
      return Center(
        child: Text(
          mensajeVacio,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.padX,
        vertical: 16,
      ),
      itemCount: reservas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TarjetaReserva(datos: reservas[i]),
    );
  }
}

class _TarjetaReserva extends StatelessWidget {
  const _TarjetaReserva({required this.datos});

  final Map<String, dynamic> datos;

  @override
  Widget build(BuildContext context) {
    final espaciado  = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme  = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => GestorNavegacion.irADetalleReservaCliente(
          context,
          datos['id'] as String,
        ),
        borderRadius: espaciado.radioCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChipEstado(estado: datos['estado'] as EstadoReserva),
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                datos['nombre'] as String,
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    datos['meta'] as String,
                    style: textTheme.bodySmall,
                  ),
                  Text(
                    datos['precio'] as String,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}