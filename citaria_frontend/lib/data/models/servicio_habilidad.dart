class ServicioHabilidad {
  final int? servicioId;
  final int? habilidadId;
  final String? nombreHabilidad;

  const ServicioHabilidad({this.servicioId, this.habilidadId, this.nombreHabilidad});

  factory ServicioHabilidad.fromJson(Map<String, dynamic> json) {
    return ServicioHabilidad(
      servicioId: json['servicioId'] == null
          ? null
          : (json['servicioId'] as num).toInt(),
      habilidadId: json['habilidadId'] == null
          ? null
          : (json['habilidadId'] as num).toInt(),
      nombreHabilidad: json['nombreHabilidad'] as String?,
    );
  }
}
