class ErrorCampo {
  final int estado;
  final String mensaje;
  final String campo;
  final DateTime timestamp;

  const ErrorCampo({
    required this.estado,
    required this.mensaje,
    required this.campo,
    required this.timestamp,
  });

  factory ErrorCampo.fromJson(Map<String, dynamic> json) {
    return ErrorCampo(
      estado: (json['estado'] as num).toInt(),
      mensaje: json['mensaje'] as String,
      campo: json['campo'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
