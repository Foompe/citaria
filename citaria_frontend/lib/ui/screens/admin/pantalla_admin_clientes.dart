import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/lista_clientes_admin.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla de listado de clientes del área admin.
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
        onPressed: () async {
          final bool? creado = await GestorNavegacion.irAAdminNuevoCliente(context);
          if (creado == true && context.mounted) {
            context.read<ViewModelAdminClientes>().refrescar();
          }
        },
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
                      onPressed: () async {
                        final bool? creado = await GestorNavegacion.irAAdminNuevoCliente(context);
                        if (creado == true && context.mounted) {
                          context.read<ViewModelAdminClientes>().refrescar();
                        }
                      },
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
            Expanded(
              child: ListaClientesAdmin(
                modoSeleccion: false,
                onTap: (cliente) async {
                  final bool? actualizado =
                      await GestorNavegacion.irAAdminDetalleCliente(
                    context,
                    cliente.id.toString(),
                  );
                  if (actualizado == true && context.mounted) {
                    context.read<ViewModelAdminClientes>().refrescar();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

