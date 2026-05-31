import 'package:flutter/foundation.dart';

@immutable
class DtoEmpresaActiva {
  const DtoEmpresaActiva({
    required this.id,
    required this.nombre,
    required this.logoUrl,
    required this.tokenRegistro,
  });

  final int id;
  final String nombre;
  final String? logoUrl;
  final String tokenRegistro;
}
