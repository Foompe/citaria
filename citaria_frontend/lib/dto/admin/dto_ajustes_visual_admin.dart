import 'package:flutter/foundation.dart';

@immutable
class DtoAjustesVisualAdmin {
  const DtoAjustesVisualAdmin({
    required this.logoUrl,
    required this.colorPrimario,
    required this.colorSecundario,
    required this.tipografia,
    required this.version,
  });

  final String logoUrl;
  final String colorPrimario;
  final String colorSecundario;
  final String tipografia;
  final String version;
}
