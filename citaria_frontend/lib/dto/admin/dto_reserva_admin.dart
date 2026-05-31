import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoReservaAdmin {
  const DtoReservaAdmin({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.fechaHoraTexto,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String cliente;
  final String servicio;
  final String empleado;
  final String fechaHoraTexto;
  final String precio;
  final EstadoReserva estado;
}
