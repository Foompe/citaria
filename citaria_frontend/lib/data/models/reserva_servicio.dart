import 'package:citaria_frontend/data/enums/estado_reserva_servicio.dart';

class ReservaServicio {
  final int? id;
  final int? reservaId;
  final int servicioId;
  final String? nombreServicio;
  final int empleadoId;
  final String? nombreEmpleado;
  final String horaInicio;
  final String horaFin;
  final double precioUnitario;
  final int? cantidad;
  final EstadoReservaServicio? estado;

  const ReservaServicio({
    this.id,
    this.reservaId,
    required this.servicioId,
    this.nombreServicio,
    required this.empleadoId,
    this.nombreEmpleado,
    required this.horaInicio,
    required this.horaFin,
    required this.precioUnitario,
    this.cantidad,
    this.estado,
  });

  factory ReservaServicio.fromJson(Map<String, dynamic> json) {
    return ReservaServicio(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      reservaId: json['reservaId'] == null
          ? null
          : (json['reservaId'] as num).toInt(),
      servicioId: (json['servicioId'] as num).toInt(),
      nombreServicio: json['nombreServicio'] as String?,
      empleadoId: (json['empleadoId'] as num).toInt(),
      nombreEmpleado: json['nombreEmpleado'] as String?,
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'] == null
          ? null
          : (json['cantidad'] as num).toInt(),
      estado: json['estado'] == null
          ? null
          : EstadoReservaServicio.fromJson(json['estado'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'servicioId': servicioId,
      'empleadoId': empleadoId,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'estado': estado?.toJson(),
    };
  }
}
