import 'package:flutter/material.dart';

@immutable
class DtoTemaEmpresa {
  const DtoTemaEmpresa({
    required this.logoUrl,
    required this.colorPrimario,
    required this.colorSecundario,
    required this.tipografia,
  });

  final String? logoUrl;
  final Color colorPrimario;
  final Color colorSecundario;
  final String? tipografia;
}
