class CierreOrganizacion {
  final int? id;
  final int? organizacionId;
  final DateTime fecha;
  final String? motivo;

  const CierreOrganizacion({
    this.id,
    this.organizacionId,
    required this.fecha,
    this.motivo,
  });

  factory CierreOrganizacion.fromJson(Map<String, dynamic> json) {
    return CierreOrganizacion(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
      motivo: json['motivo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fecha': fecha.toIso8601String().split('T').first,
      'motivo': motivo,
    };
  }
}
