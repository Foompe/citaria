import 'package:citaria_frontend/data/models/franja_horaria.dart';

class Disponibilidad {
  final DateTime fecha;
  final List<FranjaHoraria> franjas;

  const Disponibilidad({required this.fecha, required this.franjas});

  factory Disponibilidad.fromJson(Map<String, dynamic> json) {
    final List<dynamic> franjasJson = json['franjas'] as List<dynamic>;
    return Disponibilidad(
      fecha: DateTime.parse(json['fecha'] as String),
      franjas: franjasJson
          .map(
            (franja) => FranjaHoraria.fromJson(franja as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
