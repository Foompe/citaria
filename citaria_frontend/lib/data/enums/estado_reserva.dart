enum EstadoReserva {
  pendiente,
  confirmada,
  cancelada,
  completada;

  factory EstadoReserva.fromJson(String valor) {
    return EstadoReserva.values.firstWhere(
      (estado) => estado.name == valor,
      orElse: () => throw ArgumentError('EstadoReserva no válido: $valor'),
    );
  }

  String toJson() => name;
}
