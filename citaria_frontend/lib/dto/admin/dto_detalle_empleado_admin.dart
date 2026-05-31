import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleEmpleadoAdmin {
  const DtoDetalleEmpleadoAdmin({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.iniciales,
    required this.activo,
    required this.estado,
    required this.fotoUrl,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String iniciales;
  final bool activo;
  final String estado;
  final String? fotoUrl;
}
