import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoWizard {
  const DtoEmpleadoWizard({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.iniciales,
    required this.habilidades,
    required this.seleccionado,
  });

  final int? id;
  final String nombre;
  final String rol;
  final String iniciales;
  final List<String> habilidades;
  final bool seleccionado;
}
