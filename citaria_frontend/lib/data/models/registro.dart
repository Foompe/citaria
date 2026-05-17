class Registro {
  final String tokenRegistro;
  final String email;
  final String password;
  final String nombre;
  final String? apellidos;
  final String? telefono;

  const Registro({
    required this.tokenRegistro,
    required this.email,
    required this.password,
    required this.nombre,
    this.apellidos,
    this.telefono,
  });

  factory Registro.fromJson(Map<String, dynamic> json) {
    return Registro(
      tokenRegistro: json['tokenRegistro'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tokenRegistro': tokenRegistro,
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
    };
  }
}
