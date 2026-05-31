import 'package:citaria_frontend/dto/dto_linea_detalle_reserva_cliente.dart';
import 'package:citaria_frontend/dto/dto_reserva_cliente.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoDetalleReservaCliente {
  const DtoDetalleReservaCliente({
    required this.id,
    required this.estado,
    required this.servicio,
    required this.profesionalNombre,
    required this.profesionalRol,
    required this.profesionalIniciales,
    required this.fechaTexto,
    required this.horaTexto,
    required this.duracionTexto,
    required this.precioTotalTexto,
    required this.notas,
    required this.motivo,
    required this.puedeCancelar,
    required this.detalles,
  });

  final int id;
  final EstadoReservaPresentacion estado;
  final String servicio;
  final String profesionalNombre;
  final String profesionalRol;
  final String profesionalIniciales;
  final String fechaTexto;
  final String horaTexto;
  final String duracionTexto;
  final String precioTotalTexto;
  final String? notas;
  final String? motivo;
  final bool puedeCancelar;
  final List<DtoLineaDetalleReservaCliente> detalles;
}
