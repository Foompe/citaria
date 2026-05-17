class Error {
  final int estado;
  final String mensaje;
  final DateTime timestamp;

  const Error({
    required this.estado,
    required this.mensaje,
    required this.timestamp,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      estado: (json['estado'] as num).toInt(),
      mensaje: json['mensaje'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
