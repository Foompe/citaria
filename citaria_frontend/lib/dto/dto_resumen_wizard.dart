import 'package:flutter/foundation.dart';

@immutable
class DtoResumenWizard {
  const DtoResumenWizard({
    required this.serviciosTexto,
    required this.profesionalTexto,
    required this.profesionalIniciales,
    required this.fechaHoraTexto,
    required this.duracionTotalTexto,
    required this.precioTotalTexto,
    required this.puedeContinuar,
    required this.puedeConfirmar,
  });

  final String serviciosTexto;
  final String profesionalTexto;
  final String profesionalIniciales;
  final String fechaHoraTexto;
  final String duracionTotalTexto;
  final String precioTotalTexto;
  final bool puedeContinuar;
  final bool puedeConfirmar;
}
