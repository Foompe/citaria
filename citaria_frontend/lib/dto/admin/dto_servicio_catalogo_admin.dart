import 'package:flutter/foundation.dart';

@immutable
class DtoServicioCatalogoAdmin {
  const DtoServicioCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracion,
    required this.precio,
    required this.activo,
    this.imagenUrl,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String duracion;
  final String precio;
  final bool activo;
  final String? imagenUrl;
}
