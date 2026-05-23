import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_reservas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';

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

extension FiltroReservasAdminMapeo on FiltroReservasAdmin {
  FiltroAdminReservas toViewModel() {
    switch (this) {
      case FiltroReservasAdmin.hoy:
        return FiltroAdminReservas.hoy;
      case FiltroReservasAdmin.semana:
        return FiltroAdminReservas.semana;
      case FiltroReservasAdmin.pendientes:
        return FiltroAdminReservas.pendientes;
      case FiltroReservasAdmin.confirmadas:
        return FiltroAdminReservas.confirmadas;
      case FiltroReservasAdmin.canceladas:
        return FiltroAdminReservas.canceladas;
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
  late final ViewModelAdminReservas _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminReservas(
      repoReservas: context.read<RepoReservas>(),
      repoClientes: context.read<RepoClientes>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
      filtroInicial: widget.filtroInicial.toViewModel(),
    );
    _viewModel.cargarReservas();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminReservas>.value(
      value: _viewModel,
      child: const _ContenidoAdminReservas(),
    );
  }
}

class _ContenidoAdminReservas extends StatelessWidget {
  const _ContenidoAdminReservas();

  @override
  Widget build(BuildContext context) {
    final vmReservas = context.watch<ViewModelAdminReservas>();
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
                  final activo = filtro.toViewModel() == vmReservas.filtroActivo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filtro.etiqueta),
                      selected: activo,
                      onSelected: (_) =>
                          vmReservas.seleccionarFiltro(filtro.toViewModel()),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Lista de reservas ──────────────────────────────────────────
            Expanded(
              child: _ListaReservasAdmin(vmReservas: vmReservas),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaReservasAdmin extends StatelessWidget {
  const _ListaReservasAdmin({required this.vmReservas});

  final ViewModelAdminReservas vmReservas;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String? error = vmReservas.error;
    final List<DtoReservaAdmin> reservas = vmReservas.reservas;

    if (vmReservas.cargando && reservas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && reservas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: vmReservas.refrescar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (reservas.isEmpty) {
      return Center(
        child: Text(
          'No hay reservas',
          style: textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vmReservas.refrescar,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          final DtoReservaAdmin reserva = reservas[index];
          return TarjetaReservaAdmin(
            estado: _estadoVisual(reserva.estado),
            cliente: reserva.cliente,
            servicio: reserva.servicio,
            empleado: reserva.empleado,
            hora: reserva.fechaHoraTexto,
            precio: reserva.precio,
            onTap: () => GestorNavegacion.irAAdminDetalleReserva(
              context,
              reserva.id,
            ),
          );
        },
      ),
    );
  }

  chip.EstadoReserva _estadoVisual(datos.EstadoReserva estado) {
    switch (estado) {
      case datos.EstadoReserva.pendiente:
        return chip.EstadoReserva.pendiente;
      case datos.EstadoReserva.confirmada:
        return chip.EstadoReserva.confirmada;
      case datos.EstadoReserva.cancelada:
        return chip.EstadoReserva.cancelada;
      case datos.EstadoReserva.completada:
        return chip.EstadoReserva.completada;
    }
  }
}
