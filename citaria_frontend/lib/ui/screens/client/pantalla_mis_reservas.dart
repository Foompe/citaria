import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as estado_ui;
import 'package:citaria_frontend/viewmodels/viewmodel_reservas_cliente.dart';

class PantallaMisReservas extends StatefulWidget {
  const PantallaMisReservas({super.key});

  @override
  State<PantallaMisReservas> createState() => _PantallaMisReservasState();
}

class _PantallaMisReservasState extends State<PantallaMisReservas> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelReservasCliente>().cargarReservasCliente();
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;
    final reservas = context.watch<ViewModelReservasCliente>();

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
              Padding(
                padding: EdgeInsets.only(
                  left: espaciado.padX,
                  right: espaciado.padX,
                  top: 16,
                ),
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Próximas'),
                    Tab(text: 'Pasadas'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ListaReservas(
                      reservas: reservas.proximas,
                      mensajeVacio: reservas.cargando
                          ? 'Cargando reservas...'
                          : reservas.error ?? 'No tienes próximas reservas.',
                    ),
                    _ListaReservas(
                      reservas: reservas.pasadas,
                      mensajeVacio: reservas.cargando
                          ? 'Cargando reservas...'
                          : reservas.error ?? 'No tienes reservas pasadas.',
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

class _ListaReservas extends StatelessWidget {
  const _ListaReservas({required this.reservas, required this.mensajeVacio});

  final List<DtoReservaCliente> reservas;
  final String mensajeVacio;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (reservas.isEmpty) {
      return Center(
        child: Text(
          mensajeVacio,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 16),
      itemCount: reservas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TarjetaReserva(reserva: reservas[i]),
    );
  }
}

class _TarjetaReserva extends StatelessWidget {
  const _TarjetaReserva({required this.reserva});

  final DtoReservaCliente reserva;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => GestorNavegacion.irADetalleReservaCliente(
          context,
          reserva.id.toString(),
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
                  estado_ui.ChipEstado(estado: _estadoUi(reserva.estado)),
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              const SizedBox(height: 10),
              Text(reserva.nombreServicio, style: textTheme.displaySmall),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(reserva.metaFechaHora, style: textTheme.bodySmall),
                  Text(
                    reserva.precioTexto,
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

estado_ui.EstadoReserva _estadoUi(EstadoReservaPresentacion estado) {
  return switch (estado) {
    EstadoReservaPresentacion.confirmada => estado_ui.EstadoReserva.confirmada,
    EstadoReservaPresentacion.cancelada => estado_ui.EstadoReserva.cancelada,
    EstadoReservaPresentacion.completada => estado_ui.EstadoReserva.completada,
    EstadoReservaPresentacion.pendiente => estado_ui.EstadoReserva.pendiente,
  };
}
