import 'package:flutter/foundation.dart';

@immutable
class DtoClienteAdmin {
  const DtoClienteAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.iniciales,
    required this.fotoUrl,
    required this.tieneUsuario,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String dni;
  final String iniciales;
  final String? fotoUrl;
  final bool tieneUsuario;
}
