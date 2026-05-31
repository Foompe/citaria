import 'package:flutter/foundation.dart';

enum RolUsuarioPresentacion { admin, empleado, cliente }

@immutable
class DtoUsuarioSesion {
  const DtoUsuarioSesion({
    required this.email,
    required this.rol,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.fotoUrl,
    required this.iniciales,
    required this.nombreCompleto,
  });

  final String email;
  final RolUsuarioPresentacion rol;
  final String nombre;
  final String? apellidos;
  final String? telefono;
  final String? fotoUrl;
  final String iniciales;
  final String nombreCompleto;
}
