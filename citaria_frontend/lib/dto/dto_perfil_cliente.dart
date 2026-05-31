import 'package:flutter/foundation.dart';

@immutable
class DtoPerfilCliente {
  const DtoPerfilCliente({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.fotoUrl,
    required this.iniciales,
    required this.nombreCompleto,
  });

  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String? fotoUrl;
  final String iniciales;
  final String nombreCompleto;
}
