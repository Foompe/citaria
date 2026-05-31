import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/data/enums/estado_reserva_servicio.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';

/// Tests del parseo de [ReservaServicio]: casts duros de los campos
/// obligatorios y manejo de los opcionales (id, cantidad y estado null).
void main() {
  test('fromJson completo parsea todos los campos', () {
    final ReservaServicio linea = ReservaServicio.fromJson(<String, dynamic>{
      'id': 1,
      'reservaId': 2,
      'servicioId': 3,
      'nombreServicio': 'Corte',
      'empleadoId': 4,
      'nombreEmpleado': 'Ana',
      'horaInicio': '10:00',
      'horaFin': '10:30',
      'precioUnitario': 12, // num entero → se normaliza a double
      'cantidad': 2,
      'estado': 'activo',
    });

    expect(linea.id, 1);
    expect(linea.reservaId, 2);
    expect(linea.servicioId, 3);
    expect(linea.nombreServicio, 'Corte');
    expect(linea.empleadoId, 4);
    expect(linea.nombreEmpleado, 'Ana');
    expect(linea.horaInicio, '10:00');
    expect(linea.horaFin, '10:30');
    expect(linea.precioUnitario, 12.0);
    expect(linea.cantidad, 2);
    expect(linea.estado, EstadoReservaServicio.activo);
  });

  test('fromJson sin opcionales deja id, cantidad y estado a null', () {
    final ReservaServicio linea = ReservaServicio.fromJson(<String, dynamic>{
      'servicioId': 3,
      'empleadoId': 4,
      'horaInicio': '10:00',
      'horaFin': '10:30',
      'precioUnitario': 12.5,
    });

    expect(linea.id, isNull);
    expect(linea.reservaId, isNull);
    expect(linea.cantidad, isNull);
    expect(linea.estado, isNull);
    expect(linea.precioUnitario, 12.5);
  });
}
