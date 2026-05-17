class ConfiguracionVisual {
  final int? id;
  final int? organizacionId;
  final String? logoUrl;
  final String? faviconUrl;
  final String? iconoAppUrl;
  final String? colorPrimario;
  final String? colorSecundario;
  final String? tipografia;
  final int? version;

  const ConfiguracionVisual({
    this.id,
    this.organizacionId,
    this.logoUrl,
    this.faviconUrl,
    this.iconoAppUrl,
    this.colorPrimario,
    this.colorSecundario,
    this.tipografia,
    this.version,
  });

  factory ConfiguracionVisual.fromJson(Map<String, dynamic> json) {
    return ConfiguracionVisual(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      logoUrl: json['logoUrl'] as String?,
      faviconUrl: json['faviconUrl'] as String?,
      iconoAppUrl: json['iconoAppUrl'] as String?,
      colorPrimario: json['colorPrimario'] as String?,
      colorSecundario: json['colorSecundario'] as String?,
      tipografia: json['tipografia'] as String?,
      version: json['version'] == null
          ? null
          : (json['version'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'logoUrl': logoUrl,
      'faviconUrl': faviconUrl,
      'iconoAppUrl': iconoAppUrl,
      'colorPrimario': colorPrimario,
      'colorSecundario': colorSecundario,
      'tipografia': tipografia,
    };
  }
}
