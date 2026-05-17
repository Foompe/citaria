class FranjaHoraria {
  final String horaInicio;
  final String horaFin;
  final bool disponible;
  final int empleadosDisponibles;

  const FranjaHoraria({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
    required this.empleadosDisponibles,
  });

  int get duracionMinutos {
    return _parsearHora(horaFin).difference(_parsearHora(horaInicio)).inMinutes;
  }

  factory FranjaHoraria.fromJson(Map<String, dynamic> json) {
    return FranjaHoraria(
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      disponible: json['disponible'] as bool,
      empleadosDisponibles: (json['empleadosDisponibles'] as num).toInt(),
    );
  }

  static DateTime _parsearHora(String hora) {
    final List<String> partes = hora.split(':');
    return DateTime(0, 1, 1, int.parse(partes[0]), int.parse(partes[1]));
  }
}
