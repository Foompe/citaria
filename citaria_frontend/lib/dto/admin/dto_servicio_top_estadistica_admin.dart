import 'package:flutter/foundation.dart';

@immutable
class DtoServicioTopEstadisticaAdmin {
  const DtoServicioTopEstadisticaAdmin({
    required this.nombre,
    required this.detalle,
  });

  final String nombre;
  final String detalle;
}
