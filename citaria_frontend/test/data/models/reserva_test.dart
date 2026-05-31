import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/reserva.dart';

/// Tests del parseo de [Reserva]. El foco es el parseo defensivo: campos
/// opcionales ausentes/null no deben petar (ids null, listas a vacío, getter
/// de hora a cadena vacía).
void main() {
  test('fromJson completo parsea todos los campos', () {
    final Reserva reserva = Reserva.fromJson(<String, dynamic>{
      'id': 1,
      'organizacionId': 2,
      'clienteId': 3,
      'nombreCliente': 'Ana',
      'estado': 'confirmada',
      'fecha': '2026-06-01',
      'horaInicio': '10:00',
      'empleadoId': 4,
      'servicioIds': <dynamic>[5, 6],
      'notas': 'una nota',
      'motivo': 'un motivo',
      'lineas': <dynamic>[
        <String, dynamic>{
          'servicioId': 5,
          'empleadoId': 4,
          'horaInicio': '10:00',
          'horaFin': '10:30',
          'precioUnitario': 12.5,
        },
      ],
    });

    expect(reserva.id, 1);
    expect(reserva.organizacionId, 2);
    expect(reserva.clienteId, 3);
    expect(reserva.nombreCliente, 'Ana');
    expect(reserva.estado, EstadoReserva.confirmada);
    expect(reserva.fecha, DateTime(2026, 6, 1));
    expect(reserva.horaInicio, '10:00');
    expect(reserva.empleadoId, 4);
    expect(reserva.servicioIds, <int>[5, 6]);
    expect(reserva.notas, 'una nota');
    expect(reserva.motivo, 'un motivo');
    expect(reserva.lineas, hasLength(1));
    expect(reserva.lineas.first.servicioId, 5);
  });

  test('fromJson mínimo (solo fecha) no peta y aplica los valores por defecto', () {
    final Reserva reserva = Reserva.fromJson(<String, dynamic>{
      'fecha': '2026-06-01',
    });

    expect(reserva.id, isNull);
    expect(reserva.organizacionId, isNull);
    expect(reserva.clienteId, isNull);
    expect(reserva.nombreCliente, isNull);
    expect(reserva.estado, isNull);
    expect(reserva.empleadoId, isNull);
    expect(reserva.notas, isNull);
    expect(reserva.motivo, isNull);
    expect(reserva.servicioIds, isEmpty);
    expect(reserva.lineas, isEmpty);
    // horaInicio es null en el JSON → el getter devuelve cadena vacía.
    expect(reserva.horaInicio, '');
  });
}
