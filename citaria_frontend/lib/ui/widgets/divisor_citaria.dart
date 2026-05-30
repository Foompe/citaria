import 'package:flutter/material.dart';

/// Separador horizontal fino entre filas de un listado o card.
///
/// Geometría fija (`indent: 48`) alineada con las filas que llevan icono
/// a la izquierda. El color procede del esquema del tema. Cero valores
/// visuales inline en las pantallas.
class DivisorCitaria extends StatelessWidget {
  const DivisorCitaria({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
    );
  }
}
