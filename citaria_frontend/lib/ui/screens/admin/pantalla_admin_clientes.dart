import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P23 — Listado de clientes del área admin.
class PantallaAdminClientes extends StatefulWidget {
  const PantallaAdminClientes({super.key});

  @override
  State<PantallaAdminClientes> createState() => _PantallaAdminClientesState();
}

class _PantallaAdminClientesState extends State<PantallaAdminClientes> {
  late final TextEditingController _busqueda;
  late final ViewModelAdminClientes _viewModel;

  @override
  void initState() {
    super.initState();
    _busqueda = TextEditingController();
    _viewModel = ViewModelAdminClientes(
      repoClientes: context.read<RepoClientes>(),
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
    _busqueda.addListener(() => _viewModel.buscar(_busqueda.text));
    _viewModel.cargarClientes();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminClientes>.value(
      value: _viewModel,
      child: _ContenidoAdminClientes(busqueda: _busqueda),
    );
  }
}

class _ContenidoAdminClientes extends StatelessWidget {
  const _ContenidoAdminClientes({required this.busqueda});

  final TextEditingController busqueda;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.clientes,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.person_add_outlined,
        tooltip: 'Nuevo cliente',
        heroTag: 'fab-admin-clientes-nuevo',
        onPressed: () => GestorNavegacion.irAAdminNuevoCliente(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: Text('Clientes', style: textTheme.displayLarge),
                  ),
                  Tooltip(
                    message: 'Nuevo cliente',
                    child: IconButton(
                      icon: const Icon(Icons.person_add_outlined),
                      onPressed: () =>
                          GestorNavegacion.irAAdminNuevoCliente(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                12,
                espaciado.padX,
                8,
              ),
              child: TextField(
                controller: busqueda,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar cliente...',
                  border: OutlineInputBorder(
                    borderRadius: espaciado.radioInput,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: _ListaClientesAdmin(modoSeleccion: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaClientesAdmin extends StatefulWidget {
  const _ListaClientesAdmin({required this.modoSeleccion});

  final bool modoSeleccion;

  @override
  State<_ListaClientesAdmin> createState() => _ListaClientesAdminState();
}

class _ListaClientesAdminState extends State<_ListaClientesAdmin> {
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
    final vm = context.read<ViewModelAdminClientes>();
    if (vm.cargando || !vm.hayMasPaginas) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      vm.cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmClientes = context.watch<ViewModelAdminClientes>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final List<DtoClienteAdmin> clientes = vmClientes.clientes;
    final String? error = vmClientes.error;

    if (vmClientes.cargando && clientes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && clientes.isEmpty) {
      return _EstadoClientes(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmClientes.refrescar,
      );
    }

    if (clientes.isEmpty) {
      return const _EstadoClientes(mensaje: 'Sin resultados');
    }

    final bool mostrarLoader = vmClientes.hayMasPaginas;
    final int itemCount = clientes.length + (mostrarLoader ? 1 : 0);

    return RefreshIndicator(
      onRefresh: vmClientes.refrescar,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == clientes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final DtoClienteAdmin cliente = clientes[index];
          return ListTile(
            leading: AvatarFallbackCitaria(
              texto: cliente.nombreCompleto,
              imagenUrl: cliente.fotoUrl,
              tamano: 44,
              radio: 22,
            ),
            title: Text(cliente.nombreCompleto),
            subtitle: Text(
              widget.modoSeleccion ? cliente.telefono : cliente.email,
              style: textTheme.bodySmall,
            ),
            trailing: cliente.tieneUsuario
                ? Icon(Icons.verified, color: colorScheme.primary, size: 20)
                : null,
            onTap: () => GestorNavegacion.irAAdminDetalleCliente(
              context,
              cliente.id.toString(),
            ),
          );
        },
      ),
    );
  }
}

class _EstadoClientes extends StatelessWidget {
  const _EstadoClientes({
    required this.mensaje,
    this.accionTexto,
    this.onAccion,
  });

  final String mensaje;
  final String? accionTexto;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (accionTexto != null && onAccion != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAccion, child: Text(accionTexto!)),
            ],
          ],
        ),
      ),
    );
  }
}
