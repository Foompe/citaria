import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Tamaños disponibles para el Logo.
enum LogoTamano { pequeno, mediano, grande }

/// Logotipo cuadrado redondeado.
class LogoCitaria extends StatelessWidget {
  const LogoCitaria({
    super.key,
    required this.tamano,
    this.mostrarNombre = false,
  });

  final LogoTamano tamano;
  final bool mostrarNombre;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    final double lado;
    final BorderRadius radio;
    final TextStyle letraEstilo;

    switch (tamano) {
      case LogoTamano.pequeno:
        lado = 36;
        radio = espaciado.radioBoton;
        letraEstilo = textTheme.labelLarge!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );
      case LogoTamano.mediano:
        lado = 56;
        radio = espaciado.radioCard;
        letraEstilo = textTheme.displaySmall!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );
      case LogoTamano.grande:
        lado = 80;
        radio = espaciado.radioCard;
        letraEstilo = textTheme.displaySmall!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: lado,
          height: lado,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: radio,
          ),
          alignment: Alignment.center,
          child: Text('C', style: letraEstilo),
        ),
        if (mostrarNombre) ...[
          const SizedBox(height: 8),
          Text(
            'Citaria',
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}