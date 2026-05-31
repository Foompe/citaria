import 'package:flutter/foundation.dart';

@immutable
class DtoServicioCliente {
  const DtoServicioCliente({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.duracionTexto,
    required this.precioTexto,
    required this.imagenUrl,
    required this.seleccionado,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String duracionTexto;
  final String precioTexto;
  final String? imagenUrl;
  final bool seleccionado;
}
