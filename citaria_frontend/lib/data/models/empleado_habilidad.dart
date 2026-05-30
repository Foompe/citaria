class EmpleadoHabilidad {
  final int? empleadoId;
  final int? habilidadId;
  final String? nombreHabilidad;

  const EmpleadoHabilidad({this.empleadoId, this.habilidadId, this.nombreHabilidad});

  factory EmpleadoHabilidad.fromJson(Map<String, dynamic> json) {
    return EmpleadoHabilidad(
      empleadoId: json['empleadoId'] == null
          ? null
          : (json['empleadoId'] as num).toInt(),
      habilidadId: json['habilidadId'] == null
          ? null
          : (json['habilidadId'] as num).toInt(),
      nombreHabilidad: json['nombreHabilidad'] as String?,
    );
  }
}
