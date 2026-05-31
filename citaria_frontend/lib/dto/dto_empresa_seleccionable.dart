import 'package:flutter/foundation.dart';

@immutable
class DtoEmpresaSeleccionable {
  const DtoEmpresaSeleccionable({
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
