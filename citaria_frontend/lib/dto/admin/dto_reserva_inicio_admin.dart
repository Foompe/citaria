import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoReservaInicioAdmin {
  const DtoReservaInicioAdmin({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.horaInicioH,
    required this.horaInicioM,
    required this.duracionMin,
    required this.empleadoId,
    required this.estado,
  });

  final int id;
  final String cliente;
  final String servicio;
  final int horaInicioH;
  final int horaInicioM;
  final int duracionMin;
  final int empleadoId;
  final EstadoReserva estado;
}
