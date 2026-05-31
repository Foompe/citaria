import 'package:flutter/material.dart';

/// Separador horizontal fino entre filas de un listado o card.
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
