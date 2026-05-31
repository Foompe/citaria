import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/data/models/franja_horaria.dart';

/// Tests de [FranjaHoraria]: parseo y cálculo de duración a partir de las
/// horas en formato "HH:mm".
void main() {
  test('fromJson parsea los campos', () {
    final FranjaHoraria franja = FranjaHoraria.fromJson(<String, dynamic>{
      'horaInicio': '09:00',
      'horaFin': '09:30',
      'disponible': true,
      'empleadosDisponibles': 2,
    });

    expect(franja.horaInicio, '09:00');
    expect(franja.horaFin, '09:30');
    expect(franja.disponible, isTrue);
    expect(franja.empleadosDisponibles, 2);
  });

  test('duracionMinutos calcula la diferencia entre inicio y fin', () {
    const FranjaHoraria franja = FranjaHoraria(
      horaInicio: '09:00',
      horaFin: '09:30',
      disponible: true,
      empleadosDisponibles: 1,
    );

    expect(franja.duracionMinutos, 30);
  });
}
