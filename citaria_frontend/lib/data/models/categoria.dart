class Categoria {
  final int? id;
  final int? organizacionId;
  final String nombre;
  final bool? activo;

  const Categoria({
    this.id,
    this.organizacionId,
    required this.nombre,
    this.activo,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      nombre: json['nombre'] as String,
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'nombre': nombre, 'activo': activo};
  }
}
