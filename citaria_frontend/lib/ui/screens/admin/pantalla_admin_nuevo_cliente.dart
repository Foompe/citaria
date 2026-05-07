import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';

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

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlApellidos.dispose();
    _ctrlDni.dispose();
    _ctrlEmail.dispose();
    _ctrlTelefono.dispose();
    _ctrlNotas.dispose();
    super.dispose();
  }

  void _crearCliente() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: POST /clientes con los datos del formulario
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CabeceraPantalla(
        titulo: 'Nuevo cliente',
        mostrarAtras: true,
      ),
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _crearCliente,
            child: const Text('Crear cliente'),
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
            // Banner informativo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            // Nombre (required)
            _CampoFormulario(
              controller: _ctrlNombre,
              etiqueta: 'Nombre *',
              espaciado: espaciado,
              validador: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 16),

            // Apellidos
            _CampoFormulario(
              controller: _ctrlApellidos,
              etiqueta: 'Apellidos',
              espaciado: espaciado,
            ),
            const SizedBox(height: 16),

            // DNI
            _CampoFormulario(
              controller: _ctrlDni,
              etiqueta: 'DNI',
              espaciado: espaciado,
            ),
            const SizedBox(height: 16),

            // Email
            _CampoFormulario(
              controller: _ctrlEmail,
              etiqueta: 'Email',
              teclado: TextInputType.emailAddress,
              espaciado: espaciado,
            ),
            const SizedBox(height: 16),

            // Teléfono
            _CampoFormulario(
              controller: _ctrlTelefono,
              etiqueta: 'Teléfono',
              teclado: TextInputType.phone,
              espaciado: espaciado,
            ),
            const SizedBox(height: 16),

            // Notas
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
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  const _CampoFormulario({
    required this.controller,
    required this.etiqueta,
    required this.espaciado,
    this.teclado,
    this.validador,
  });

  final TextEditingController controller;
  final String etiqueta;
  final EspaciadoCitaria espaciado;
  final TextInputType? teclado;
  final String? Function(String?)? validador;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(
          borderRadius: espaciado.radioInput,
        ),
      ),
    );
  }
}