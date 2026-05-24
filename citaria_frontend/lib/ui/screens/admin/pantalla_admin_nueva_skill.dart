import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PantallaAdminNuevaSkill extends StatefulWidget {
  const PantallaAdminNuevaSkill({super.key});

  @override
  State<PantallaAdminNuevaSkill> createState() =>
      _PantallaAdminNuevaSkillState();
}

class _PantallaAdminNuevaSkillState extends State<PantallaAdminNuevaSkill> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlDescripcion = TextEditingController();
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
    _ctrlDescripcion.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _crearSkill() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final skill = await _viewModel.crearSkill(
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
    );

    if (!mounted) {
      return;
    }

    if (skill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear la skill.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Skill creada')));
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
                onPressed: vmCatalogo.cargando ? null : _crearSkill,
                child: vmCatalogo.cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear skill'),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                const CabeceraTituloGrande(
                  titulo: 'Nueva skill',
                  mostrarAtras: true,
                ),
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
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ctrlDescripcion,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        alignLabelWithHint: true,
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
