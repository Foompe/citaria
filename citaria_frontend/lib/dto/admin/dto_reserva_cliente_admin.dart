import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoReservaClienteAdmin {
  const DtoReservaClienteAdmin({
    required this.id,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.estado,
  });

  final String id;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final EstadoReserva estado;
}
