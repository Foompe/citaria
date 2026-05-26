class PeriodoDisponibles {
  final List<DateTime> fechasDisponibles;

  const PeriodoDisponibles({required this.fechasDisponibles});

  factory PeriodoDisponibles.fromJson(Map<String, dynamic> json) {
    final List<dynamic> fechasJson =
        json['fechasDisponibles'] as List<dynamic>? ?? <dynamic>[];
    return PeriodoDisponibles(
      fechasDisponibles: fechasJson.map((f) {
        final DateTime parsed = DateTime.parse(f as String);
        return DateTime(parsed.year, parsed.month, parsed.day);
      }).toList(growable: false),
    );
  }
}
