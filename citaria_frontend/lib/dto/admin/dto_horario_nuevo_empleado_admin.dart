import 'package:citaria_frontend/utils/formato_hora.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoHorarioNuevoEmpleadoAdmin {
  const DtoHorarioNuevoEmpleadoAdmin({
    required this.diaSemana,
    required this.dia,
    required this.activo,
    required this.horaInicio,
    required this.horaFin,
  });

  final int diaSemana;
  final String dia;
  final bool activo;
  final String horaInicio;
  final String horaFin;

  String get horario =>
      '${formatearHoraHm(horaInicio)} - '
      '${formatearHoraHm(horaFin)}';

  DtoHorarioNuevoEmpleadoAdmin copyWith({bool? activo}) {
    return DtoHorarioNuevoEmpleadoAdmin(
      diaSemana: diaSemana,
      dia: dia,
      activo: activo ?? this.activo,
      horaInicio: horaInicio,
      horaFin: horaFin,
    );
  }
}
