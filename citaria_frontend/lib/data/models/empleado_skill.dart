class EmpleadoSkill {
  final int? empleadoId;
  final int? skillId;
  final String? nombreSkill;

  const EmpleadoSkill({this.empleadoId, this.skillId, this.nombreSkill});

  factory EmpleadoSkill.fromJson(Map<String, dynamic> json) {
    return EmpleadoSkill(
      empleadoId: json['empleadoId'] == null
          ? null
          : (json['empleadoId'] as num).toInt(),
      skillId: json['skillId'] == null
          ? null
          : (json['skillId'] as num).toInt(),
      nombreSkill: json['nombreSkill'] as String?,
    );
  }
}
