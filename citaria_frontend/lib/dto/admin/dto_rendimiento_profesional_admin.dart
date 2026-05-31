import 'package:flutter/foundation.dart';

@immutable
class DtoRendimientoProfesionalAdmin {
  const DtoRendimientoProfesionalAdmin({
    required this.nombre,
    required this.reservas,
    required this.cancelaciones,
    required this.facturacionTexto,
  });

  final String nombre;
  final double reservas;
  final double cancelaciones;
  final String facturacionTexto;
}
