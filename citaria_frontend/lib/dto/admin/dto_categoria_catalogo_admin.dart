import 'package:flutter/foundation.dart';

@immutable
class DtoCategoriaCatalogoAdmin {
  const DtoCategoriaCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  final int id;
  final String nombre;
  final bool activo;
}
