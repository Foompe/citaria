import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/data/models/periodo_disponibles.dart';

/// Tests de [PeriodoDisponibles]: normaliza cada fecha a solo año/mes/día
/// (descartando la hora) y tolera la lista ausente.
void main() {
  test('fromJson trunca la hora y deja solo la fecha', () {
    final PeriodoDisponibles periodo = PeriodoDisponibles.fromJson(<String, dynamic>{
      'fechasDisponibles': <dynamic>['2026-06-01T14:30:00'],
    });

    expect(periodo.fechasDisponibles, <DateTime>[DateTime(2026, 6, 1)]);
    expect(periodo.fechasDisponibles.first.hour, 0);
  });

  test('fromJson sin lista devuelve vacío', () {
    final PeriodoDisponibles periodo =
        PeriodoDisponibles.fromJson(<String, dynamic>{});

    expect(periodo.fechasDisponibles, isEmpty);
  });
}
