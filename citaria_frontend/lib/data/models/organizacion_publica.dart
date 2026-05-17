class OrganizacionPublica {
  final int? id;
  final String? nombre;
  final String? logoUrl;
  final String? tokenRegistro;

  const OrganizacionPublica({
    this.id,
    this.nombre,
    this.logoUrl,
    this.tokenRegistro,
  });

  factory OrganizacionPublica.fromJson(Map<String, dynamic> json) {
    return OrganizacionPublica(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      nombre: json['nombre'] as String?,
      logoUrl: json['logoUrl'] as String?,
      tokenRegistro: json['tokenRegistro'] as String?,
    );
  }
}
