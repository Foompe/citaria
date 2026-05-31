import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleClienteAdmin {
  const DtoDetalleClienteAdmin({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.nombreCompleto,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.notas,
    required this.iniciales,
    required this.fotoUrl,
    required this.tieneUsuario,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String nombreCompleto;
  final String dni;
  final String email;
  final String telefono;
  final String? notas;
  final String iniciales;
  final String? fotoUrl;
  final bool tieneUsuario;
}
