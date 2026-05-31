import 'package:flutter/foundation.dart';

@immutable
class DtoAjustesEmpresaAdmin {
  const DtoAjustesEmpresaAdmin({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.cif,
    required this.calle,
    required this.codigoPostal,
    required this.ciudad,
    required this.pais,
  });

  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String cif;
  final String calle;
  final String codigoPostal;
  final String ciudad;
  final String pais;
}
