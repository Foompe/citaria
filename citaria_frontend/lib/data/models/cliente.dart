class Cliente {
  final int? id;
  final int? organizacionId;
  final String nombre;
  final String? apellidos;
  final String? dni;
  final String? email;
  final String? telefono;
  final String? notas;
  final String? fotoUrl;
  final DateTime? anonimizadoAt;
  final bool tieneUsuario;

  const Cliente({
    this.id,
    this.organizacionId,
    required this.nombre,
    this.apellidos,
    this.dni,
    this.email,
    this.telefono,
    this.notas,
    this.fotoUrl,
    this.anonimizadoAt,
    required this.tieneUsuario,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String?,
      dni: json['dni'] as String?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      notas: json['notas'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      anonimizadoAt: json['anonimizadoAt'] == null
          ? null
          : DateTime.parse(json['anonimizadoAt'] as String),
      tieneUsuario: json['tieneUsuario'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
      'email': email,
      'telefono': telefono,
      'notas': notas,
      'fotoUrl': fotoUrl,
    };
  }
}
