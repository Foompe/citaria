import 'package:flutter/foundation.dart';

@immutable
class DtoKpiDobleEstadisticaAdmin {
  const DtoKpiDobleEstadisticaAdmin({
    required this.titulo,
    required this.valorHoy,
    required this.valorMes,
  });

  final String titulo;
  final String valorHoy;
  final String valorMes;
}
