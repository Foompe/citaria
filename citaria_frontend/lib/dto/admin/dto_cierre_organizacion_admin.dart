import 'package:flutter/foundation.dart';

@immutable
class DtoCierreOrganizacionAdmin {
  const DtoCierreOrganizacionAdmin({
    required this.id,
    required this.fecha,
    required this.motivo,
  });

  final int id;
  final String fecha;
  final String motivo;
}
