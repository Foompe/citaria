import 'package:flutter/foundation.dart';

@immutable
class DtoAjustesCuentaAdmin {
  const DtoAjustesCuentaAdmin({
    required this.email,
    required this.rol,
    required this.estado,
  });

  final String email;
  final String rol;
  final String estado;
}
