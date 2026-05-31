import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/disponibilidad.dart';
import 'package:citaria_frontend/data/models/franja_horaria.dart';
import 'package:citaria_frontend/data/models/periodo_disponibles.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_disponibilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_wizard.dart';

/// Doble de [RepoDisponibilidad] con control manual del orden de respuestas.
///
/// `obtener` no resuelve sola: guarda un [Completer] por fecha que el test
/// completa cuando quiere, permitiendo simular respuestas fuera de orden.
class _RepoDisponibilidadFake extends RepoDisponibilidad {
  _RepoDisponibilidadFake(super.api);

  Set<DateTime> diasDisponibles = <DateTime>{};
  final Map<String, Completer<Disponibilidad>> _pendientes =
      <String, Completer<Disponibilidad>>{};

  @override
  Future<PeriodoDisponibles> obtenerDiasDisponiblesPeriodo(
    DateTime fechaInicio,
    DateTime fechaFin,
    List<int> servicioIds,
    String token, {
    int? empleadoId,
  }) async {
    return PeriodoDisponibles(
      fechasDisponibles: diasDisponibles.toList(growable: false),
    );
  }

  @override
  Future<Disponibilidad> obtener(
    DateTime fecha,
    List<int> servicioIds,
    String token, {
    int? empleadoId,
  }) {
    final Completer<Disponibilidad> completer = Completer<Disponibilidad>();
    _pendientes[_clave(fecha)] = completer;
    return completer.future;
  }

  /// Resuelve la petición pendiente de [fecha] con las franjas dadas.
  void resolver(DateTime fecha, Disponibilidad disponibilidad) {
    _pendientes[_clave(fecha)]!.complete(disponibilidad);
  }

  String _clave(DateTime fecha) => '${fecha.year}-${fecha.month}-${fecha.day}';
}

Disponibilidad _disponibilidadCon(DateTime fecha, String horaInicio) {
  return Disponibilidad(
    fecha: fecha,
    franjas: <FranjaHoraria>[
      FranjaHoraria(
        horaInicio: horaInicio,
        horaFin: '18:00',
        disponible: true,
        empleadosDisponibles: 1,
      ),
    ],
  );
}

void main() {
  // Fechas futuras (no hoy) para que las franjas no se marquen como pasadas.
  final DateTime fechaA = DateTime(2099, 1, 1);
  final DateTime fechaB = DateTime(2099, 1, 2);

  late _RepoDisponibilidadFake repoDisponibilidad;
  late ViewModelWizard vm;

  setUpAll(() async {
    // El VM construye un DateFormat('es_ES'); necesita los datos de locale.
    await initializeDateFormatting('es_ES', null);
  });

  setUp(() async {
    final CitariaApi api = CitariaApi(http.Client());
    repoDisponibilidad = _RepoDisponibilidadFake(api)
      ..diasDisponibles = <DateTime>{fechaA, fechaB};
    vm = ViewModelWizard(
      repoCatalogo: RepoCatalogo(api),
      repoReservas: RepoReservas(api),
      repoDisponibilidad: repoDisponibilidad,
      token: 'token-test',
      organizacionId: 1,
    );

    // Estado mínimo para poder seleccionar fechas: un servicio elegido y la
    // caché de días disponibles cargada con A y B.
    await vm.toggleServicio(1);
    await vm.cargarDiasDisponibles();
  });

  test('carga las franjas de la fecha seleccionada', () async {
    final Future<void> seleccion = vm.seleccionarFecha(fechaA);
    repoDisponibilidad.resolver(fechaA, _disponibilidadCon(fechaA, '09:00'));
    await seleccion;

    expect(vm.fechaSeleccionada, fechaA);
    expect(vm.franjas.single.horaInicio, '09:00');
  });

  test(
    'descarta la respuesta obsoleta cuando se cambia de fecha mientras carga',
    () async {
      // Dos selecciones encadenadas sin esperar: ambas peticiones quedan
      // en vuelo (A primero, B después → B es la fecha vigente).
      final Future<void> seleccionA = vm.seleccionarFecha(fechaA);
      final Future<void> seleccionB = vm.seleccionarFecha(fechaB);

      // Las respuestas llegan en orden inverso: B (vigente) y luego A (tardía).
      // Sin la guarda, la respuesta de A sobrescribiría las franjas de B.
      repoDisponibilidad.resolver(fechaB, _disponibilidadCon(fechaB, '10:00'));
      repoDisponibilidad.resolver(fechaA, _disponibilidadCon(fechaA, '17:00'));

      await Future.wait(<Future<void>>[seleccionA, seleccionB]);

      // La fecha vigente es B → las franjas deben ser las de B, nunca las de A.
      expect(vm.fechaSeleccionada, fechaB);
      expect(vm.franjas.single.horaInicio, '10:00');
    },
  );
}
