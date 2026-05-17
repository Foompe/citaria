class DiasDisponibles {
  final List<int> diasDisponibles;

  const DiasDisponibles({required this.diasDisponibles});

  factory DiasDisponibles.fromJson(Map<String, dynamic> json) {
    final List<dynamic> diasJson =
        json['diasDisponibles'] as List<dynamic>? ?? <dynamic>[];
    return DiasDisponibles(
      diasDisponibles: diasJson
          .map((dia) => (dia as num).toInt())
          .toList(growable: false),
    );
  }
}
