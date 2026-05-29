import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PantallaAdminNuevaCategoria extends StatefulWidget {
  const PantallaAdminNuevaCategoria({super.key});

  @override
  State<PantallaAdminNuevaCategoria> createState() =>
      _PantallaAdminNuevaCategoriaState();
}

class _PantallaAdminNuevaCategoriaState
    extends State<PantallaAdminNuevaCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  late final ViewModelAdminCatalogo _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _crearCategoria() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final categoria = await _viewModel.crearCategoria(nombre: _ctrlNombre.text);

    if (!mounted) {
      return;
    }

    if (categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear la categoría.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Categoría creada')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) => Scaffold(
          bottomNavigationBar: BarraCtaFija(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vmCatalogo.cargando ? null : _crearCategoria,
                child: vmCatalogo.cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear categoría'),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                const CabeceraTituloGrande(titulo: 'Nueva categoría'),
              ],
              body: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    espaciado.padX,
                    24,
                    espaciado.padX,
                    120,
                  ),
                  children: [
                    TextFormField(
                      controller: _ctrlNombre,
                      textInputAction: TextInputAction.done,
                      validator: (valor) => valor == null || valor.trim().isEmpty
                          ? 'El nombre es obligatorio'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Nombre *',
                        border: OutlineInputBorder(
                          borderRadius: espaciado.radioInput,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
