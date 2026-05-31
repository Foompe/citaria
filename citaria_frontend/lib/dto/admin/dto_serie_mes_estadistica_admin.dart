import 'package:flutter/foundation.dart';

@immutable
class DtoSerieMesEstadisticaAdmin {
  const DtoSerieMesEstadisticaAdmin({
    required this.periodo,
    required this.valor1,
    required this.valor2,
  });

  final String periodo;
  final double valor1;
  final double valor2;
}
