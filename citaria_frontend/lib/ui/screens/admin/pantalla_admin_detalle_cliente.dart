import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late final ViewModelAdminClientes _viewModel;
  int? _clienteId;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = ViewModelAdminClientes(
      repoClientes: context.read<RepoClientes>(),
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;
    final int? id = _leerIdCliente(context);
    _clienteId = id;
    if (id != null) {
      _viewModel.cargarDetalleCliente(id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminClientes>.value(
      value: _viewModel,
      child: _ContenidoDetalleCliente(
        tabController: _tabController,
        clienteId: _clienteId,
      ),
    );
  }

  int? _leerIdCliente(BuildContext context) {
    final Object? argumentos = ModalRoute.of(context)?.settings.arguments;
    if (argumentos is Map<String, dynamic>) {
      final Object? id = argumentos['id'];
      if (id is int) {
        return id;
      }
      if (id is String) {
        return int.tryParse(id);
      }
    }
    return null;
  }
}

class _ContenidoDetalleCliente extends StatelessWidget {
  const _ContenidoDetalleCliente({
    required this.tabController,
    required this.clienteId,
  });

  final TabController tabController;
  final int? clienteId;

  @override
  Widget build(BuildContext context) {
    final vmClientes = context.watch<ViewModelAdminClientes>();
    final detalle = vmClientes.detalle;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Cliente',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Actualizar',
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: clienteId == null
                ? null
                : () => vmClientes.cargarDetalleCliente(clienteId!),
          ),
        ),
      ),
      body: _CuerpoDetalleCliente(
        clienteId: clienteId,
        detalle: detalle,
        reservas: vmClientes.reservasCliente,
        vmClientes: vmClientes,
        tabController: tabController,
        espaciado: espaciado,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}

class _CuerpoDetalleCliente extends StatelessWidget {
  const _CuerpoDetalleCliente({
    required this.clienteId,
    required this.detalle,
    required this.reservas,
    required this.vmClientes,
    required this.tabController,
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final int? clienteId;
  final DtoDetalleClienteAdmin? detalle;
  final List<DtoReservaClienteAdmin> reservas;
  final ViewModelAdminClientes vmClientes;
  final TabController tabController;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (clienteId == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado el cliente.',
        accionTexto: 'Volver',
        onAccion: () => Navigator.maybePop(context),
      );
    }

    if (vmClientes.cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmClientes.error;
    if (error != null && detalle == null) {
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vmClientes.cargarDetalleCliente(clienteId!),
      );
    }

    final DtoDetalleClienteAdmin? cliente = detalle;
    if (cliente == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado el cliente.',
        accionTexto: 'Reintentar',
        onAccion: () => vmClientes.cargarDetalleCliente(clienteId!),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 16),
          child: Column(
            children: [
              AvatarFallbackCitaria(
                texto: cliente.nombreCompleto,
                tamano: 72,
                radio: 36,
              ),
              const SizedBox(height: 12),
              Text(
                cliente.nombreCompleto,
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                cliente.email,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Datos'),
            Tab(text: 'Reservas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _TabDatos(
                cliente: cliente,
                vmClientes: vmClientes,
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
              _TabReservas(
                reservas: reservas,
                clienteNombre: cliente.nombreCompleto,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabDatos extends StatelessWidget {
  const _TabDatos({
    required this.cliente,
    required this.vmClientes,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final DtoDetalleClienteAdmin cliente;
  final ViewModelAdminClientes vmClientes;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    final campos = [
      (Icons.person_outline, 'Nombre', cliente.nombre),
      (Icons.group_outlined, 'Apellidos', cliente.apellidos),
      (Icons.badge_outlined, 'DNI', cliente.dni),
      (Icons.email_outlined, 'Email', cliente.email),
      (Icons.phone_outlined, 'Teléfono', cliente.telefono),
      if (cliente.notas != null)
        (Icons.notes_outlined, 'Notas', cliente.notas!),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 24),
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
                  subtitle: Text(campos[i].$3, style: textTheme.bodyLarge),
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
          onPressed: vmClientes.cargando
              ? null
              : () => _darDeBaja(context, vmClientes, cliente.id),
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }

  Future<void> _darDeBaja(
    BuildContext context,
    ViewModelAdminClientes vmClientes,
    int id,
  ) async {
    final bool ok = await vmClientes.darDeBajaCliente(id);
    if (!context.mounted) {
      return;
    }
    if (ok) {
      Navigator.maybePop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vmClientes.error ?? 'No se pudo dar de baja.')),
    );
  }
}

class _TabReservas extends StatelessWidget {
  const _TabReservas({
    required this.reservas,
    required this.clienteNombre,
  });

  final List<DtoReservaClienteAdmin> reservas;
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
        final DtoReservaClienteAdmin reserva = reservas[index];
        return TarjetaReservaAdmin(
          estado: _estadoVisual(reserva.estado),
          cliente: clienteNombre,
          servicio: reserva.servicio,
          empleado: reserva.empleado,
          hora: reserva.hora,
          precio: reserva.precio,
          onTap: () =>
              GestorNavegacion.irAAdminDetalleReserva(context, reserva.id),
        );
      },
    );
  }
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
