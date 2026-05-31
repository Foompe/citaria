import 'package:flutter/foundation.dart';

@immutable
class DtoDiaWizard {
  const DtoDiaWizard({
    required this.fecha,
    required this.dia,
    required this.esDelMes,
    required this.disponible,
    required this.seleccionado,
    required this.esHoy,
  });

  final DateTime fecha;
  final int dia;
  final bool esDelMes;
  final bool disponible;
  final bool seleccionado;
  final bool esHoy;
}
