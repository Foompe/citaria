import 'package:flutter/foundation.dart';

@immutable
class DtoCategoriaCliente {
  const DtoCategoriaCliente({
    required this.id,
    required this.nombre,
    required this.activa,
  });

  final int? id;
  final String nombre;
  final bool activa;
}
