import 'package:flutter/foundation.dart';

@immutable
class DtoHorarioOrganizacionAdmin {
  const DtoHorarioOrganizacionAdmin({
    required this.id,
    required this.diaSemana,
    required this.dia,
    required this.activo,
    required this.horario,
    required this.horaApertura,
    required this.horaCierre,
  });

  final int? id;
  final int diaSemana;
  final String dia;
  final bool activo;
  final String horario;
  final String horaApertura;
  final String horaCierre;
}
