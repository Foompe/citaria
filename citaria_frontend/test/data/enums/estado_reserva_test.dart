import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/data/enums/estado_reserva.dart';

/// Tests de [EstadoReserva.fromJson]: mapea el nombre al enum y rechaza
/// valores desconocidos.
void main() {
  test('fromJson mapea un valor válido', () {
    expect(EstadoReserva.fromJson('pendiente'), EstadoReserva.pendiente);
    expect(EstadoReserva.fromJson('completada'), EstadoReserva.completada);
  });

  test('fromJson lanza ArgumentError con un valor desconocido', () {
    expect(() => EstadoReserva.fromJson('otro'), throwsArgumentError);
  });
}
