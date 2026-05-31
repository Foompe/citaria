import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoAdmin {
  const DtoEmpleadoAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.iniciales,
    required this.activo,
    required this.estado,
    required this.resumen,
    required this.fotoUrl,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String iniciales;
  final bool activo;
  final String estado;
  final String resumen;
  final String? fotoUrl;
}
