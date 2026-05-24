import 'package:flutter/material.dart';

/// Teclado numérico reutilizable para los diálogos de PIN.
///
/// Muestra una cuadrícula 3×4: 1–9 / ← 0 ✓.
/// El botón ✓ se deshabilita cuando [onConfirmar] es null.
class TecladoPinCitaria extends StatelessWidget {
  const TecladoPinCitaria({
    super.key,
    required this.onDigito,
    required this.onBorrar,
    required this.onConfirmar,
  });

  final ValueChanged<int> onDigito;
  final VoidCallback onBorrar;
  final VoidCallback? onConfirmar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
