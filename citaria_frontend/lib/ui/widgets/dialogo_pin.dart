import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Diálogo modal de verificación de PIN para zonas protegidas.
///
/// Muestra el nombre de la [seccion] destino en el subtítulo.
/// Devuelve [true] si el PIN es correcto, [null] si el usuario cancela.
///
/// Uso desde [GestorNavegacion]:
/// ```dart
/// final ok = await showDialog<bool>(
///   context: context,
///   builder: (_) => DialogoPin(seccion: 'Empleados'),
/// );
/// ```
///
/// TODO: validar PIN contra API o almacenamiento local seguro.
/// Por ahora cualquier entrada no vacía da acceso.
class DialogoPin extends StatefulWidget {
  const DialogoPin({
    super.key,
    required this.seccion,
  });

  /// Nombre de la sección destino mostrado en el subtítulo.
  final String seccion;

  @override
  State<DialogoPin> createState() => _DialogoPinState();
}

class _DialogoPinState extends State<DialogoPin> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continuar() {
    // TODO: validar PIN contra API o almacenamiento local seguro.
    // Por ahora cualquier entrada no vacía da acceso.
    if (_controller.text.isEmpty) {
      setState(() => _error = true);
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _cancelar() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono candado
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: espaciado.radioCard,
            ),
            child: Icon(
              Icons.lock_outline,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Título
          Text('Zona protegida', style: textTheme.displaySmall),
          const SizedBox(height: 6),

          // Subtítulo con nombre de sección en negrita
          Text.rich(
            TextSpan(
              text: 'Introduce la contraseña para acceder a ',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
              children: [
                TextSpan(
                  text: widget.seccion,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '. Se pide cada vez por seguridad.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campo PIN
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: true,
            autofocus: true,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _continuar(),
            onChanged: (_) {
              if (_error) setState(() => _error = false);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: espaciado.radioInput,
              ),
              errorText: _error ? 'Introduce el PIN' : null,
            ),
          ),
        ],
      ),
      actions: [
        // Botones: Cancelar + Continuar
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  onPressed: _cancelar,
                  child: const Text('Cancelar'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _continuar,
                  child: const Text('Continuar'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}