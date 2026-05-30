import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';

/// Chip visual "Activo / Inactivo" para recursos con estado lógico
/// (servicios, categorías, habilidades, empleados).
///
/// Reutiliza los colores de [EstadosReservaCitaria] (confirmada = activo,
/// completada = inactivo) y la geometría de [EspaciadoCitaria.radioPill].
/// Cero valores visuales inline.
class ChipActivoInactivo extends StatelessWidget {
  const ChipActivoInactivo({super.key, required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final estados   = Theme.of(context).extension<EstadosReservaCitaria>()!;
    final textTheme = Theme.of(context).textTheme;
    final ColoresEstado colores =
        activo ? estados.confirmada : estados.completada;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: textTheme.labelSmall?.copyWith(color: colores.texto),
      ),
    );
  }
}
