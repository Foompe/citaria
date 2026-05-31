import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoInicioAdmin {
  const DtoEmpleadoInicioAdmin({
    required this.id,
    required this.nombre,
    required this.fotoUrl,
  });

  final int id;
  final String nombre;
  final String? fotoUrl;
}
