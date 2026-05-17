class Servicio {
  final int? id;
  final int? organizacionId;
  final int? categoriaId;
  final String? nombreCategoria;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final double precio;
  final int duracionMinutos;
  final bool? activo;

  const Servicio({
    this.id,
    this.organizacionId,
    this.categoriaId,
    this.nombreCategoria,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    required this.precio,
    required this.duracionMinutos,
    this.activo,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      categoriaId: json['categoriaId'] == null
          ? null
          : (json['categoriaId'] as num).toInt(),
      nombreCategoria: json['nombreCategoria'] as String?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
      precio: (json['precio'] as num).toDouble(),
      duracionMinutos: (json['duracionMinutos'] as num).toInt(),
      activo: json['activo'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categoriaId': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'precio': precio,
      'duracionMinutos': duracionMinutos,
      'activo': activo,
    };
  }
}
