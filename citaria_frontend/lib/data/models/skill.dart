class Skill {
  final int? id;
  final int? organizacionId;
  final String nombre;
  final String? descripcion;
  final bool? activo;

  const Skill({
    this.id,
    this.organizacionId,
    required this.nombre,
    this.descripcion,
    this.activo,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
