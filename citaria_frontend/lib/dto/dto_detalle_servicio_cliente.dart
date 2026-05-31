import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleServicioCliente {
  const DtoDetalleServicioCliente({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.duracionTexto,
    required this.precioTexto,
    required this.imagenUrl,
    required this.habilidades,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String duracionTexto;
  final String precioTexto;
  final String? imagenUrl;
  final List<String> habilidades;
}
