import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/disponibilidad.dart';
import 'package:citaria_frontend/data/models/franja_horaria.dart';
import 'package:citaria_frontend/data/models/periodo_disponibles.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_disponibilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/dto/dto_dia_wizard.dart';
import 'package:citaria_frontend/dto/dto_franja_wizard.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_wizard.dart';

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

/// Doble de [RepoCatalogo] que devuelve un catálogo fijo de servicios, para
/// poder seleccionar servicios reales y calcular duración/precio.
class _RepoCatalogoFake extends RepoCatalogo {
  _RepoCatalogoFake(super.api);

  @override
  Future<List<Servicio>> listarServicios(String token) async {
    return const <Servicio>[
      Servicio(id: 1, nombre: 'Corte', precio: 10.0, duracionMinutos: 30, activo: true),
      Servicio(id: 2, nombre: 'Tinte', precio: 25.5, duracionMinutos: 45, activo: true),
    ];
  }
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
      repoCatalogo: _RepoCatalogoFake(api),
      repoReservas: RepoReservas(api),
      repoDisponibilidad: repoDisponibilidad,
      token: 'token-test',
      organizacionId: 1,
    );

    // Estado mínimo para poder seleccionar fechas: catálogo cargado, un
    // servicio elegido y la caché de días disponibles cargada con A y B.
    await vm.inicializar();
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

  test('duracionTotalMinutos suma los servicios seleccionados', () async {
    expect(vm.duracionTotalMinutos, 30); // solo el 1 (de setUp)
    await vm.toggleServicio(2);
    expect(vm.duracionTotalMinutos, 75); // 30 + 45
    await vm.toggleServicio(1);
    await vm.toggleServicio(2);
    expect(vm.duracionTotalMinutos, 0);
  });

  test('precioTotal suma los precios de los servicios seleccionados', () async {
    expect(vm.precioTotal, closeTo(10.0, 0.0001)); // solo el 1
    await vm.toggleServicio(2);
    expect(vm.precioTotal, closeTo(35.5, 0.0001)); // 10.0 + 25.5
  });

  test('diasCalendario genera semanas completas con relleno', () {
    final List<DtoDiaWizard> dias = vm.diasCalendario;

    // La rejilla es siempre un número entero de semanas.
    expect(dias.length % 7, 0);

    // Tantas celdas del mes como días tiene el mes actual.
    final DateTime ahora = DateTime.now();
    final int diasEnMes = DateTime(ahora.year, ahora.month + 1, 0).day;
    expect(dias.where((d) => d.esDelMes).length, diasEnMes);

    // Las celdas de relleno van con dia 0 y nunca disponibles.
    expect(
      dias.where((d) => !d.esDelMes).every((d) => d.dia == 0 && !d.disponible),
      isTrue,
    );

    // Hoy aparece exactamente una vez entre las celdas del mes.
    expect(dias.where((d) => d.esDelMes && d.esHoy).length, 1);
  });

  test('franjas: marca como pasada la franja temprana si la fecha es hoy', () async {
    final DateTime hoy = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    repoDisponibilidad.diasDisponibles = <DateTime>{hoy};
    await vm.cargarDiasDisponibles();

    final Future<void> seleccion = vm.seleccionarFecha(hoy);
    repoDisponibilidad.resolver(
      hoy,
      Disponibilidad(
        fecha: hoy,
        franjas: const <FranjaHoraria>[
          FranjaHoraria(
            horaInicio: '00:00',
            horaFin: '00:15',
            disponible: true,
            empleadosDisponibles: 1,
          ),
          FranjaHoraria(
            horaInicio: '23:59',
            horaFin: '23:59',
            disponible: true,
            empleadosDisponibles: 1,
          ),
        ],
      ),
    );
    await seleccion;

    final List<DtoFranjaWizard> franjas = vm.franjas;
    expect(franjas[0].horaInicio, '00:00');
    expect(franjas[0].disponible, isFalse); // ya pasó (hoy)
    expect(franjas[1].horaInicio, '23:59');
    expect(franjas[1].disponible, isTrue); // aún por venir
  });

  test('franjas: una franja temprana en fecha futura NO se marca pasada', () async {
    final Future<void> seleccion = vm.seleccionarFecha(fechaA);
    repoDisponibilidad.resolver(fechaA, _disponibilidadCon(fechaA, '00:00'));
    await seleccion;

    // fechaA es 2099 → la regla de "ya pasó" solo aplica a hoy.
    expect(vm.franjas.single.disponible, isTrue);
  });
}
