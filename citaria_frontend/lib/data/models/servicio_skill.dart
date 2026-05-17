class ServicioSkill {
  final int? servicioId;
  final int? skillId;
  final String? nombreSkill;

  const ServicioSkill({this.servicioId, this.skillId, this.nombreSkill});

  factory ServicioSkill.fromJson(Map<String, dynamic> json) {
    return ServicioSkill(
      servicioId: json['servicioId'] == null
          ? null
          : (json['servicioId'] as num).toInt(),
      skillId: json['skillId'] == null
          ? null
          : (json['skillId'] as num).toInt(),
      nombreSkill: json['nombreSkill'] as String?,
    );
  }
}
