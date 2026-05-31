import 'package:flutter/foundation.dart';

@immutable
class DtoFranjaWizard {
  const DtoFranjaWizard({
    required this.horaInicio,
    required this.horaFin,
    required this.horaTexto,
    required this.disponible,
    required this.seleccionada,
    required this.empleadosDisponibles,
  });

  final String horaInicio;
  final String horaFin;
  final String horaTexto;
  final bool disponible;
  final bool seleccionada;
  final int empleadosDisponibles;
}
