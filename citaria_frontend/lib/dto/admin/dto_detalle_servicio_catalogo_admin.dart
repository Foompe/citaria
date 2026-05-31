import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleServicioCatalogoAdmin {
  const DtoDetalleServicioCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionMinutos,
    required this.categoriaId,
    required this.activo,
    required this.habilidadIds,
    this.imagenUrl,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMinutos;
  final int? categoriaId;
  final bool activo;
  final Set<int> habilidadIds;
  final String? imagenUrl;
}
