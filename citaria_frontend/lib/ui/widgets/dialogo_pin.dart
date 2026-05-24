import 'package:citaria_frontend/data/services/servicio_pin.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/teclado_pin_citaria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Diálogo modal de verificación de PIN para zonas protegidas.
///
/// Muestra el nombre de la [seccion] destino en el subtítulo.
/// Devuelve [true] si el PIN es correcto, [null] si el usuario cancela.
/// Acepta entre 4 y 8 dígitos.
class DialogoPin extends StatefulWidget {
  const DialogoPin({super.key, required this.seccion});

  final String seccion;

  @override
  State<DialogoPin> createState() => _DialogoPinState();
}

class _DialogoPinState extends State<DialogoPin> {
  final List<int> _digitos = [];
  bool _verificando = false;
  bool _pinInvalido = false;

  static const int _minDigitos = 4;
  static const int _maxDigitos = 8;

  bool get _puedeConfirmar =>
      _digitos.length >= _minDigitos && !_verificando && !_pinInvalido;

  void _pulsarDigito(int digito) {
    if (_digitos.length >= _maxDigitos || _pinInvalido) return;
    setState(() => _digitos.add(digito));
  }

  void _borrarDigito() {
    if (_digitos.isEmpty) return;
    setState(() => _digitos.removeLast());
  }

  Future<void> _continuar() async {
    if (!_puedeConfirmar) return;

    setState(() => _verificando = true);
    final bool ok = await context.read<ServicioPin>().verificar(
      _digitos.join(),
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _verificando = false;
        _pinInvalido = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _pinInvalido = false;
            _digitos.clear();
          });
        }
      });
    }
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
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: espaciado.radioCard,
            ),
            child: Icon(Icons.lock_outline, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Zona protegida', style: textTheme.displaySmall),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: 'Introduce la contraseña para acceder a ',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              children: [
                TextSpan(
                  text: widget.seccion,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Indicadores de punto
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_maxDigitos, (i) {
                final bool relleno = i < _digitos.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinInvalido && relleno
                          ? colorScheme.error
                          : relleno
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Mensaje de error
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: _pinInvalido
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'PIN incorrecto',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          TecladoPinCitaria(
            onDigito: _pulsarDigito,
            onBorrar: _borrarDigito,
            onConfirmar: _puedeConfirmar ? _continuar : null,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _verificando ? null : _cancelar,
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}
