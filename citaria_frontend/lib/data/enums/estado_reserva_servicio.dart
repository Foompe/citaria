enum EstadoReservaServicio {
  activo,
  cancelado;

  factory EstadoReservaServicio.fromJson(String valor) {
    return EstadoReservaServicio.values.firstWhere(
      (estado) => estado.name == valor,
      orElse: () =>
          throw ArgumentError('EstadoReservaServicio no válido: $valor'),
    );
  }

  String toJson() => name;
}
