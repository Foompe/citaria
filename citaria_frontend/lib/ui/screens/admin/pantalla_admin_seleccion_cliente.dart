import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P22 — Selección de cliente para nueva reserva.
///
/// Ruta: /admin/nueva-reserva/cliente
/// Argument opcional 'modoSeleccion' (bool) — por defecto true.
class PantallaAdminSeleccionCliente extends StatefulWidget {
  const PantallaAdminSeleccionCliente({super.key});

  @override
  State<PantallaAdminSeleccionCliente> createState() =>
      _PantallaAdminSeleccionClienteState();
}

class _PantallaAdminSeleccionClienteState
    extends State<PantallaAdminSeleccionCliente> {
  late final TextEditingController _busqueda;
  late final ViewModelAdminClientes _viewModel;

  @override
  void initState() {
    super.initState();
    _busqueda = TextEditingController();
    _viewModel = ViewModelAdminClientes(
      repoClientes: context.read<RepoClientes>(),
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

  bool _esModoSeleccion(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['modoSeleccion'] as bool? ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminClientes>.value(
      value: _viewModel,
      child: _ContenidoSeleccionCliente(
        busqueda: _busqueda,
        modoSeleccion: _esModoSeleccion(context),
      ),
    );
  }
}

class _ContenidoSeleccionCliente extends StatelessWidget {
  const _ContenidoSeleccionCliente({
    required this.busqueda,
    required this.modoSeleccion,
  });

  final TextEditingController busqueda;
  final bool modoSeleccion;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: modoSeleccion ? 'Seleccionar cliente' : 'Clientes',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Nuevo cliente',
          child: IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => GestorNavegacion.irAAdminNuevoCliente(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              espaciado.padX,
              16,
              espaciado.padX,
              8,
            ),
            child: TextField(
              controller: busqueda,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar cliente...',
                border: OutlineInputBorder(borderRadius: espaciado.radioInput),
              ),
            ),
          ),
          Expanded(child: _ListaSeleccionClientes(modoSeleccion: modoSeleccion)),
        ],
      ),
    );
  }
}

class _ListaSeleccionClientes extends StatelessWidget {
  const _ListaSeleccionClientes({required this.modoSeleccion});

  final bool modoSeleccion;

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

    return RefreshIndicator(
      onRefresh: vmClientes.refrescar,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: clientes.length,
        itemBuilder: (context, index) {
          final DtoClienteAdmin cliente = clientes[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                cliente.iniciales,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(cliente.nombreCompleto),
            subtitle: Text(
              modoSeleccion ? cliente.telefono : cliente.email,
              style: textTheme.bodySmall,
            ),
            onTap: () {
              if (modoSeleccion) {
                GestorNavegacion.irAWizardServicios(
                  context,
                  clienteId: cliente.id,
                  origen: OrigenWizard.admin,
                );
                return;
              }
              GestorNavegacion.irAAdminDetalleCliente(
                context,
                cliente.id.toString(),
              );
            },
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
