import 'package:flutter/foundation.dart';

@immutable
class DtoHabilidadCatalogoAdmin {
  const DtoHabilidadCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final bool activo;
}
