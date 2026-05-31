import 'package:flutter/foundation.dart';

@immutable
class DtoLineaDetalleReservaAdmin {
  const DtoLineaDetalleReservaAdmin({
    required this.servicio,
    required this.empleado,
    required this.fotoUrlEmpleado,
    required this.horarioTexto,
    required this.duracionTexto,
    required this.precioTexto,
    required this.estadoTexto,
  });

  final String servicio;
  final String empleado;
  final String? fotoUrlEmpleado;
  final String horarioTexto;
  final String duracionTexto;
  final String precioTexto;
  final String? estadoTexto;
}
