import 'package:flutter/foundation.dart';

@immutable
class DtoServicioWizard {
  const DtoServicioWizard({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionTexto,
    required this.precioTexto,
    required this.seleccionado,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String duracionTexto;
  final String precioTexto;
  final bool seleccionado;
}
