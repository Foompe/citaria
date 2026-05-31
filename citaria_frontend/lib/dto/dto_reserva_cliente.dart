import 'package:flutter/foundation.dart';

enum EstadoReservaPresentacion { pendiente, confirmada, cancelada, completada }

@immutable
class DtoReservaCliente {
  const DtoReservaCliente({
    required this.id,
    required this.estado,
    required this.nombreServicio,
    required this.metaFechaHora,
    required this.precioTexto,
    required this.esProxima,
  });

  final int id;
  final EstadoReservaPresentacion estado;
  final String nombreServicio;
  final String metaFechaHora;
  final String precioTexto;
  final bool esProxima;
}
