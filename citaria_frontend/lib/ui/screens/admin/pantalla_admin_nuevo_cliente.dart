import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/campo_formulario.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P24 — Formulario de alta de nuevo cliente en el área admin.
///
/// Ruta: /admin/clientes/nuevo
class PantallaAdminNuevoCliente extends StatefulWidget {
  const PantallaAdminNuevoCliente({super.key});

  @override
  State<PantallaAdminNuevoCliente> createState() =>
      _PantallaAdminNuevoClienteState();
}

class _PantallaAdminNuevoClienteState
    extends State<PantallaAdminNuevoCliente> {
  final _formKey        = GlobalKey<FormState>();
  final _ctrlNombre     = TextEditingController();
  final _ctrlApellidos  = TextEditingController();
  final _ctrlDni        = TextEditingController();
  final _ctrlEmail      = TextEditingController();
  final _ctrlTelefono   = TextEditingController();
  final _ctrlNotas      = TextEditingController();
  late final ViewModelAdminClientes _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminClientes(
      repoClientes: context.read<RepoClientes>(),
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlApellidos.dispose();
    _ctrlDni.dispose();
    _ctrlEmail.dispose();
    _ctrlTelefono.dispose();
    _ctrlNotas.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _crearCliente() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cliente = await _viewModel.crearCliente(
      nombre: _ctrlNombre.text,
      apellidos: _ctrlApellidos.text,
      dni: _ctrlDni.text,
      email: _ctrlEmail.text,
      telefono: _ctrlTelefono.text,
      notas: _ctrlNotas.text,
    );

    if (!mounted) {
      return;
    }

    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear el cliente.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente creado')),
    );
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return ChangeNotifierProvider<ViewModelAdminClientes>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminClientes>(
        builder: (context, vmClientes, _) => Scaffold(
          appBar: const CabeceraPantalla(
            titulo: 'Nuevo cliente',
            mostrarAtras: true,
          ),
          bottomNavigationBar: BarraCtaFija(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vmClientes.cargando ? null : _crearCliente,
                child: vmClientes.cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cliente'),
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX,
                120,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: espaciado.radioCard,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Este cliente no tendrá cuenta en la app',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CampoFormulario(
                  controller: _ctrlNombre,
                  etiqueta: 'Nombre *',
                  validador: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 16),

                CampoFormulario(
                  controller: _ctrlApellidos,
                  etiqueta: 'Apellidos',
                ),
                const SizedBox(height: 16),

                CampoFormulario(
                  controller: _ctrlDni,
                  etiqueta: 'DNI',
                ),
                const SizedBox(height: 16),

                CampoFormulario(
                  controller: _ctrlEmail,
                  etiqueta: 'Email',
                  teclado: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CampoFormulario(
                  controller: _ctrlTelefono,
                  etiqueta: 'Teléfono',
                  teclado: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _ctrlNotas,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas',
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
    );
  }
}

