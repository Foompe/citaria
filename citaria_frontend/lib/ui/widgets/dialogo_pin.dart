import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:flutter/material.dart';

/// Diálogo modal de verificación de PIN para zonas protegidas.
///
/// Muestra el nombre de la [seccion] destino en el subtítulo.
/// Devuelve [true] si el PIN es correcto, [null] si el usuario cancela.
/// Acepta entre 4 y 8 dígitos.
///
/// TODO: validar PIN contra API o almacenamiento local seguro.
/// Por ahora cualquier entrada de 4–8 dígitos da acceso.
class DialogoPin extends StatefulWidget {
  const DialogoPin({super.key, required this.seccion});

  final String seccion;

  @override
  State<DialogoPin> createState() => _DialogoPinState();
}

class _DialogoPinState extends State<DialogoPin> {
  final List<int> _digitos = [];

  static const int _minDigitos = 4;
  static const int _maxDigitos = 8;

  bool get _puedeConfirmar => _digitos.length >= _minDigitos;

  void _pulsarDigito(int digito) {
    if (_digitos.length >= _maxDigitos) return;
    setState(() => _digitos.add(digito));
  }

  void _borrarDigito() {
    if (_digitos.isEmpty) return;
    setState(() => _digitos.removeLast());
  }

  void _continuar() {
    if (!_puedeConfirmar) return;
    Navigator.of(context).pop(true);
  }

  void _cancelar() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Indicadores de puntos (máx. 8)
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
                      color: relleno
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Teclado numérico
          _TecladoPin(
            onDigito: _pulsarDigito,
            onBorrar: _borrarDigito,
            onConfirmar: _puedeConfirmar ? _continuar : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _cancelar,
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}

// ── Teclado ────────────────────────────────────────────────────────────────────

class _TecladoPin extends StatelessWidget {
  const _TecladoPin({
    required this.onDigito,
    required this.onBorrar,
    required this.onConfirmar,
    required this.colorScheme,
  });

  final ValueChanged<int> onDigito;
  final VoidCallback onBorrar;
  final VoidCallback? onConfirmar;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilaTeclas(digitos: const [1, 2, 3], onDigito: onDigito),
        const SizedBox(height: 8),
        _FilaTeclas(digitos: const [4, 5, 6], onDigito: onDigito),
        const SizedBox(height: 8),
        _FilaTeclas(digitos: const [7, 8, 9], onDigito: onDigito),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Tecla(
              onPressed: onBorrar,
              child: Icon(
                Icons.backspace_outlined,
                size: 20,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            _Tecla(
              onPressed: () => onDigito(0),
              child: const Text('0', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
            _Tecla(
              onPressed: onConfirmar,
              child: Icon(
                Icons.check,
                size: 20,
                color: onConfirmar != null
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilaTeclas extends StatelessWidget {
  const _FilaTeclas({required this.digitos, required this.onDigito});

  final List<int> digitos;
  final ValueChanged<int> onDigito;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < digitos.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _Tecla(
            onPressed: () => onDigito(digitos[i]),
            child: Text('${digitos[i]}', style: const TextStyle(fontSize: 20)),
          ),
        ],
      ],
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({required this.child, required this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
