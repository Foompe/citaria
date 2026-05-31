import 'package:citaria_frontend/data/enums/estado_reserva.dart';
import 'package:citaria_frontend/dto/admin/dto_linea_detalle_reserva_admin.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleReservaAdmin {
  const DtoDetalleReservaAdmin({
    required this.id,
    required this.estado,
    required this.cliente,
    required this.clienteId,
    required this.telefono,
    required this.fotoUrlCliente,
    required this.servicio,
    required this.duracion,
    required this.empleado,
    required this.fotoUrlEmpleado,
    required this.fecha,
    required this.hora,
    required this.total,
    required this.observaciones,
    required this.motivo,
    required this.puedeConfirmar,
    required this.puedeCancelar,
    required this.puedeCambiarEstado,
    required this.lineas,
  });

  final String id;
  final EstadoReserva estado;
  final String cliente;
  final String? clienteId;
  final String? telefono;
  final String? fotoUrlCliente;
  final String servicio;
  final String duracion;
  final String empleado;
  final String? fotoUrlEmpleado;
  final String fecha;
  final String hora;
  final String total;
  final String? observaciones;
  final String? motivo;
  final bool puedeConfirmar;
  final bool puedeCancelar;
  final bool puedeCambiarEstado;
  final List<DtoLineaDetalleReservaAdmin> lineas;
}
