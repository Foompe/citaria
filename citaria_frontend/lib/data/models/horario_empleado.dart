class HorarioEmpleado {
  final int? id;
  final int? empleadoId;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;

  const HorarioEmpleado({
    this.id,
    this.empleadoId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
  });

  factory HorarioEmpleado.fromJson(Map<String, dynamic> json) {
    return HorarioEmpleado(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      empleadoId: json['empleadoId'] == null
          ? null
          : (json['empleadoId'] as num).toInt(),
      diaSemana: (json['diaSemana'] as num).toInt(),
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'activo': activo,
    };
  }
}
