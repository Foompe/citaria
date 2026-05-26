import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/data/models/reserva_servicio.dart';

class Reserva {
  final int? id;
  final int? organizacionId;
  final int? clienteId;
  final String? nombreCliente;
  final EstadoReserva? estado;
  final DateTime fecha;
  final String? _horaInicio;
  final int? empleadoId;
  final List<int> servicioIds;
  final String? notas;
  final String? motivo;
  final List<ReservaServicio> lineas;

  const Reserva({
    this.id,
    this.organizacionId,
    this.clienteId,
    this.nombreCliente,
    this.estado,
    required this.fecha,
    required String? horaInicio,
    this.empleadoId,
    required this.servicioIds,
    this.notas,
    this.motivo,
    this.lineas = const <ReservaServicio>[],
  }) : _horaInicio = horaInicio;

  String get horaInicio => _horaInicio ?? '';

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final List<dynamic> servicioIdsJson =
        json['servicioIds'] as List<dynamic>? ?? <dynamic>[];
    return Reserva(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      clienteId: json['clienteId'] == null
          ? null
          : (json['clienteId'] as num).toInt(),
      nombreCliente: json['nombreCliente'] as String?,
      estado: json['estado'] == null
          ? null
          : EstadoReserva.fromJson(json['estado'] as String),
      fecha: DateTime.parse(json['fecha'] as String),
      horaInicio: json['horaInicio'] as String?,
      empleadoId: json['empleadoId'] == null
          ? null
          : (json['empleadoId'] as num).toInt(),
      servicioIds: servicioIdsJson
          .map((servicioId) => (servicioId as num).toInt())
          .toList(),
      notas: json['notas'] as String?,
      motivo: json['motivo'] as String?,
      lineas: (json['lineas'] as List<dynamic>?)
              ?.map(
                (l) => ReservaServicio.fromJson(l as Map<String, dynamic>),
              )
              .toList(growable: false) ??
          const <ReservaServicio>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fecha': fecha.toIso8601String().split('T').first,
      'horaInicio': horaInicio,
      'empleadoId': empleadoId,
      'servicioIds': servicioIds,
      'notas': notas,
      'motivo': motivo,
    };
  }
}
