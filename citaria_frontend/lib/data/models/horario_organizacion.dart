class HorarioOrganizacion {
  final int? id;
  final int? organizacionId;
  final int diaSemana;
  final String horaApertura;
  final String horaCierre;
  final bool activo;

  const HorarioOrganizacion({
    this.id,
    this.organizacionId,
    required this.diaSemana,
    required this.horaApertura,
    required this.horaCierre,
    required this.activo,
  });

  factory HorarioOrganizacion.fromJson(Map<String, dynamic> json) {
    return HorarioOrganizacion(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      diaSemana: (json['diaSemana'] as num).toInt(),
      horaApertura: json['horaApertura'] as String,
      horaCierre: json['horaCierre'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'diaSemana': diaSemana,
      'horaApertura': horaApertura,
      'horaCierre': horaCierre,
      'activo': activo,
    };
  }
}
