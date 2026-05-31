import 'package:flutter/foundation.dart';

@immutable
class DtoItemEstadisticaAdmin {
  const DtoItemEstadisticaAdmin({
    required this.nombre,
    required this.valor,
    required this.valorTexto,
    required this.porcentaje,
    required this.porcentajeTexto,
  });

  final String nombre;
  final double valor;
  final String valorTexto;
  final double? porcentaje;
  final String? porcentajeTexto;
}
