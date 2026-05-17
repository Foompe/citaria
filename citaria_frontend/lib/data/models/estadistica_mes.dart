class EstadisticaMes {
  final String? periodo;
  final double? valor1;
  final double? valor2;

  const EstadisticaMes({this.periodo, this.valor1, this.valor2});

  factory EstadisticaMes.fromJson(Map<String, dynamic> json) {
    return EstadisticaMes(
      periodo: json['periodo'] as String?,
      valor1: json['valor1'] == null
          ? null
          : (json['valor1'] as num).toDouble(),
      valor2: json['valor2'] == null
          ? null
          : (json['valor2'] as num).toDouble(),
    );
  }
}
