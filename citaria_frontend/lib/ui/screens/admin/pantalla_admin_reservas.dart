import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_categoria.dart';
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
      repoEmpleados: context.read<RepoEmpleados>(),
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
              height: 36,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                scrollDirection: Axis.horizontal,
                itemCount: FiltroReservasAdmin.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final filtro = FiltroReservasAdmin.values[i];
                  final activo = filtro.toViewModel() == vmReservas.filtroActivo;
                  return GestureDetector(
                    onTap: () =>
                        vmReservas.seleccionarFiltro(filtro.toViewModel()),
                    child: ChipCategoria(
                      etiqueta: filtro.etiqueta,
                      activo: activo,
                    ),
                  );
                },
              ),
            ),

            // ── Lista de reservas ──────────────────────────────────────────
            const Expanded(
              child: _ListaReservasAdmin(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaReservasAdmin extends StatefulWidget {
  const _ListaReservasAdmin();

  @override
  State<_ListaReservasAdmin> createState() => _ListaReservasAdminState();
}

class _ListaReservasAdminState extends State<_ListaReservasAdmin> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vm = context.read<ViewModelAdminReservas>();
    if (vm.cargando || !vm.hayMasPaginas) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      vm.cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmReservas = context.watch<ViewModelAdminReservas>();
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
          _mensajeVacio(vmReservas.filtroActivo),
          style: textTheme.bodyLarge,
        ),
      );
    }

    final bool mostrarLoader = vmReservas.hayMasPaginas;
    final int itemCount = reservas.length + (mostrarLoader ? 1 : 0);

    return RefreshIndicator(
      onRefresh: vmReservas.refrescar,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == reservas.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
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

  String _mensajeVacio(FiltroAdminReservas filtro) {
    return switch (filtro) {
      FiltroAdminReservas.hoy => 'No hay reservas para hoy',
      FiltroAdminReservas.semana => 'No hay reservas esta semana',
      FiltroAdminReservas.pendientes => 'No hay reservas pendientes',
      FiltroAdminReservas.confirmadas => 'No hay reservas confirmadas',
      FiltroAdminReservas.canceladas => 'No hay reservas canceladas',
    };
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
