import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Tamaños disponibles para [LogoCitaria].
enum LogoTamano { pequeno, mediano, grande }

/// Logotipo cuadrado redondeado de Citaria.
///
/// Muestra la inicial «C» sobre fondo [colorScheme.primary].
/// Si [mostrarNombre] es true, añade el nombre de la empresa debajo.
///
/// Tamaños:
///   pequeno → 36×36  radio: radioBoton
///   mediano → 56×56  radio: radioCard
///   grande  → 80×80  radio: radioCard  (radioLogo no existe en EspaciadoCitaria;
///                                       se usa radioCard = 16 px por acuerdo
///                                       documentado en el informe de Bloque 1)
///
/// Escala tipográfica:
///   pequeno → textTheme.labelLarge   (sustituye titleMedium — fuera de escala)
///   mediano → textTheme.displaySmall (sustituye titleLarge  — fuera de escala)
///   grande  → textTheme.displaySmall (sin cambio)
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
        // TODO: sustituir por espaciado.radioLogo cuando se añada
        // radioLogo a EspaciadoCitaria. Por acuerdo Bloque 1 se usa
        // radioCard (16 px).
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
            // TODO: leer de configuración de empresa.
            // Por ahora hardcodeado.
            'Citaria',
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}