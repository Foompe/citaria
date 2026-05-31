import 'package:flutter/foundation.dart';

@immutable
class DtoHabilidadDisponibleEmpleadoAdmin {
  const DtoHabilidadDisponibleEmpleadoAdmin({
    required this.id,
    required this.nombre,
  });

  final int id;
  final String nombre;
}
