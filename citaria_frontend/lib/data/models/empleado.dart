class Empleado {
  final int? id;
  final int? organizacionId;
  final String nombre;
  final String apellidos;
  final String? email;
  final String? telefono;
  final String? fotoUrl;
  final bool? activo;
  final DateTime? anonimizadoAt;

  const Empleado({
    this.id,
    this.organizacionId,
    required this.nombre,
    required this.apellidos,
    this.email,
    this.telefono,
    this.fotoUrl,
    this.activo,
    this.anonimizadoAt,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      activo: json['activo'] as bool?,
      anonimizadoAt: json['anonimizadoAt'] == null
          ? null
          : DateTime.parse(json['anonimizadoAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'activo': activo,
    };
  }
}
