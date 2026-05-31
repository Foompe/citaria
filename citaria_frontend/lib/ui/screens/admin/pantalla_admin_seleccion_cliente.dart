import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/lista_clientes_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_wizard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla de selección de cliente para nueva reserva.
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
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CabeceraTituloGrande(
              titulo: modoSeleccion ? 'Seleccionar cliente' : 'Clientes',
              accionDerecha: Tooltip(
                message: 'Nuevo cliente',
                child: IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: () =>
                      GestorNavegacion.irAAdminNuevoCliente(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  0,
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
            ),
          ],
          body: ListaClientesAdmin(
            modoSeleccion: modoSeleccion,
            onTap: (cliente) {
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
          ),
        ),
      ),
    );
  }
}

