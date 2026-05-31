import 'package:flutter/foundation.dart';

@immutable
class DtoReservaCreada {
  const DtoReservaCreada({
    required this.id,
    required this.fechaTexto,
    required this.horaTexto,
  });

  final int id;
  final String fechaTexto;
  final String horaTexto;
}
