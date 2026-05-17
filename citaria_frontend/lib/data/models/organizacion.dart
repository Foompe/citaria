class Organizacion {
  final int? id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? cif;
  final String? calle;
  final String? codigoPostal;
  final String? ciudad;
  final String pais;
  final String? tokenRegistro;

  const Organizacion({
    this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.cif,
    this.calle,
    this.codigoPostal,
    this.ciudad,
    required this.pais,
    this.tokenRegistro,
  });

  factory Organizacion.fromJson(Map<String, dynamic> json) {
    return Organizacion(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      cif: json['cif'] as String?,
      calle: json['calle'] as String?,
      codigoPostal: json['codigoPostal'] as String?,
      ciudad: json['ciudad'] as String?,
      pais: json['pais'] as String,
      tokenRegistro: json['tokenRegistro'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'cif': cif,
      'calle': calle,
      'codigoPostal': codigoPostal,
      'ciudad': ciudad,
      'pais': pais,
    };
  }
}
