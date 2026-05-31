import 'package:flutter/foundation.dart';

@immutable
class DtoLineaDetalleReservaCliente {
  const DtoLineaDetalleReservaCliente({
    required this.servicio,
    required this.profesional,
    required this.horaTexto,
    required this.duracionTexto,
    required this.precioTexto,
    required this.cantidadTexto,
    required this.estadoTexto,
  });

  final String servicio;
  final String profesional;
  final String horaTexto;
  final String duracionTexto;
  final String precioTexto;
  final String? cantidadTexto;
  final String? estadoTexto;
}
