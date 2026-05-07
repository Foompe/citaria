import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';

/// Estados posibles de una reserva Citaria.
enum EstadoReserva { pendiente, confirmada, cancelada, completada }

/// Chip visual que representa el estado de una reserva.
///
/// Los colores proceden de [EstadosReservaCitaria] y la geometría
/// de [EspaciadoCitaria.radioPill]. Cero valores visuales inline.
class ChipEstado extends StatelessWidget {
  const ChipEstado({
    super.key,
    required this.estado,
  });

  final EstadoReserva estado;

  String get _etiqueta {
    switch (estado) {
      case EstadoReserva.pendiente:
        return 'Pendiente';
      case EstadoReserva.confirmada:
        return 'Confirmada';
      case EstadoReserva.cancelada:
        return 'Cancelada';
      case EstadoReserva.completada:
        return 'Completada';
    }
  }

  ColoresEstado _colores(EstadosReservaCitaria estados) {
    switch (estado) {
      case EstadoReserva.pendiente:
        return estados.pendiente;
      case EstadoReserva.confirmada:
        return estados.confirmada;
      case EstadoReserva.cancelada:
        return estados.cancelada;
      case EstadoReserva.completada:
        return estados.completada;
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final estados   = Theme.of(context).extension<EstadosReservaCitaria>()!;
    final textTheme = Theme.of(context).textTheme;
    final colores   = _colores(estados);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        _etiqueta,
        style: textTheme.labelSmall?.copyWith(color: colores.texto),
      ),
    );
  }
}