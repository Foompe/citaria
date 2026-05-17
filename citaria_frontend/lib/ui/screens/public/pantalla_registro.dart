import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';

/// P05 — Registro.
///
/// Formulario de alta de nuevo usuario con todos los campos
/// definidos en el prompt: nombre, apellidos, DNI (opcional),
/// email, teléfono y contraseña.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _controladorNombre = TextEditingController();
  final TextEditingController _controladorApellidos = TextEditingController();
  final TextEditingController _controladorDni = TextEditingController();
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorTelefono = TextEditingController();
  final TextEditingController _controladorPassword = TextEditingController();
  final TextEditingController _controladorRepeatPassword =
      TextEditingController();

  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorApellidos.dispose();
    _controladorDni.dispose();
    _controladorEmail.dispose();
    _controladorTelefono.dispose();
    _controladorPassword.dispose();
    _controladorRepeatPassword.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    final String nombre = _controladorNombre.text.trim();
    final String email = _controladorEmail.text.trim();

    if (nombre.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y email son obligatorios.')),
      );
      return;
    }

    if (_controladorPassword.text != _controladorRepeatPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final String apellidos = _controladorApellidos.text.trim();
    final String telefono = _controladorTelefono.text.trim();
    final vmAuth = context.read<ViewModelAutenticacion>();
    final vmTema = context.read<ViewModelTema>();
    final destino = await vmAuth.registrar(
      nombre: nombre,
      apellidos: apellidos.isEmpty ? null : apellidos,
      email: email,
      telefono: telefono.isEmpty ? null : telefono,
      password: _controladorPassword.text,
      tema: vmTema,
    );

    if (!mounted) return;

    final String? mensajeError = vmAuth.error;
    if (destino != null) {
      GestorNavegacion.irASplashPostAutenticacion(context);
    } else if (mensajeError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensajeError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final vmAuth = context.watch<ViewModelAutenticacion>();

    return Scaffold(
      appBar: const CabeceraPantalla(titulo: 'Únete', mostrarAtras: true),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            espaciado.padX,
            24,
            espaciado.padX,
            espaciado.safeBottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CampoFormulario(
                label: 'Nombre',
                controller: _controladorNombre,
                hint: 'Nombre',
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              _CampoFormulario(
                label: 'Apellidos',
                controller: _controladorApellidos,
                hint: 'Apellidos',
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              _CampoFormulario(
                label: 'DNI (opcional)',
                controller: _controladorDni,
                hint: '00000000X',
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 14),
              _CampoFormulario(
                label: 'Email',
                controller: _controladorEmail,
                hint: 'tu@email.com',
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _CampoFormulario(
                label: 'Teléfono',
                controller: _controladorTelefono,
                hint: '+34 600 000 000',
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _CampoPassword(
                label: 'Contraseña',
                controller: _controladorPassword,
                hint: 'Contraseña',
                visible: _passwordVisible,
                onToggleVisible: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
              const SizedBox(height: 14),
              _CampoPassword(
                label: 'Repite la contraseña',
                controller: _controladorRepeatPassword,
                hint: 'Repite la contraseña',
                visible: _repeatPasswordVisible,
                onToggleVisible: () => setState(
                  () => _repeatPasswordVisible = !_repeatPasswordVisible,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: vmAuth.cargando ? null : _continuar,
                child: const Text('Continuar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _mostrarDialogoVincularCuenta(context),
                child: const Text('Vincular'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoPassword extends StatelessWidget {
  const _CampoPassword({
    required this.label,
    required this.controller,
    required this.hint,
    required this.visible,
    required this.onToggleVisible,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool visible;
  final VoidCallback onToggleVisible;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              tooltip: visible ? 'Ocultar contraseña' : 'Mostrar contraseña',
              icon: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: onToggleVisible,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  const _CampoFormulario({
    required this.label,
    required this.controller,
    required this.hint,
    required this.inputType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

void _mostrarDialogoVincularCuenta(BuildContext context) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final TextTheme textTheme = Theme.of(context).textTheme;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Cuenta encontrada', style: textTheme.displaySmall),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Ya existe una cuenta asociada a este email. ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
                children: [
                  TextSpan(
                    text: 'Puedes vincularla',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' para conservar tus datos o crear una cuenta nueva.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      GestorNavegacion.irASplash(context);
                    },
                    child: const Text('Crear nueva'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      GestorNavegacion.irASplash(context);
                    },
                    child: const Text('Vincular'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
