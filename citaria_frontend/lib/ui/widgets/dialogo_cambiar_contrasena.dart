import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:flutter/material.dart';

typedef _CambiarContrasena = Future<String?> Function(
  String passwordActual,
  String passwordNueva,
);

/// Diálogo de cambio de contraseña.
/// Recibe [onCambiar] que devuelve null si todo fue bien o el mensaje de error.
/// Devuelve [true] al guardar correctamente, [false] si el usuario cancela.
class DialogoCambiarContrasena extends StatefulWidget {
  const DialogoCambiarContrasena({super.key, required this.onCambiar});

  final _CambiarContrasena onCambiar;

  @override
  State<DialogoCambiarContrasena> createState() =>
      _DialogoCambiarContrasenaState();
}

class _DialogoCambiarContrasenaState extends State<DialogoCambiarContrasena> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlActual = TextEditingController();
  final _ctrlNueva = TextEditingController();
  final _ctrlConfirmar = TextEditingController();

  bool _guardando = false;
  final List<bool> _ver = [false, false, false];
  String? _errorServidor;

  @override
  void dispose() {
    _ctrlActual.dispose();
    _ctrlNueva.dispose();
    _ctrlConfirmar.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _guardando = true;
      _errorServidor = null;
    });

    final String? error =
        await widget.onCambiar(_ctrlActual.text, _ctrlNueva.text);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _guardando = false;
        _errorServidor = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: espaciado.radioCard,
            ),
            child: Icon(
              Icons.lock_reset_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text('Cambiar contraseña', style: textTheme.displaySmall),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CampoPassword(
                controller: _ctrlActual,
                etiqueta: 'Contraseña actual',
                ver: _ver[0],
                onVerCambiado: (v) => setState(() => _ver[0] = v),
                validador: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Introduce tu contraseña actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _CampoPassword(
                controller: _ctrlNueva,
                etiqueta: 'Nueva contraseña',
                ver: _ver[1],
                onVerCambiado: (v) => setState(() => _ver[1] = v),
                validador: (valor) {
                  if (valor == null || valor.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _CampoPassword(
                controller: _ctrlConfirmar,
                etiqueta: 'Confirmar nueva contraseña',
                ver: _ver[2],
                onVerCambiado: (v) => setState(() => _ver[2] = v),
                accionTeclado: TextInputAction.done,
                onEnviar: (_) => _guardar(),
                validador: (valor) {
                  if (valor != _ctrlNueva.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              if (_errorServidor != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorServidor!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

class _CampoPassword extends StatelessWidget {
  const _CampoPassword({
    required this.controller,
    required this.etiqueta,
    required this.ver,
    required this.onVerCambiado,
    required this.validador,
    this.accionTeclado = TextInputAction.next,
    this.onEnviar,
  });

  final TextEditingController controller;
  final String etiqueta;
  final bool ver;
  final ValueChanged<bool> onVerCambiado;
  final FormFieldValidator<String> validador;
  final TextInputAction accionTeclado;
  final ValueChanged<String>? onEnviar;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return TextFormField(
      controller: controller,
      obscureText: !ver,
      textInputAction: accionTeclado,
      onFieldSubmitted: onEnviar,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: espaciado.radioInput),
        suffixIcon: IconButton(
          icon: Icon(ver ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => onVerCambiado(!ver),
        ),
      ),
    );
  }
}
