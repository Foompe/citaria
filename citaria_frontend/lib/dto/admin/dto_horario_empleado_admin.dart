import 'package:flutter/foundation.dart';

@immutable
class DtoHorarioEmpleadoAdmin {
  const DtoHorarioEmpleadoAdmin({
    required this.id,
    required this.diaSemana,
    required this.dia,
    required this.activo,
    required this.horario,
    required this.horaInicio,
    required this.horaFin,
  });

  final int? id;
  final int diaSemana;
  final String dia;
  final bool activo;
  final String horario;
  final String horaInicio;
  final String horaFin;
}
