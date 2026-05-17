class EstadisticaItem {
  final int? id;
  final String? nombre;
  final double? valor;
  final double? porcentaje;

  const EstadisticaItem({this.id, this.nombre, this.valor, this.porcentaje});

  factory EstadisticaItem.fromJson(Map<String, dynamic> json) {
    return EstadisticaItem(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      nombre: json['nombre'] as String?,
      valor: json['valor'] == null ? null : (json['valor'] as num).toDouble(),
      porcentaje: json['porcentaje'] == null
          ? null
          : (json['porcentaje'] as num).toDouble(),
    );
  }
}
