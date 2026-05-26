import 'package:citaria_frontend/data/models/reserva.dart';

class PaginaReservas {
  final List<Reserva> content;
  final int totalPages;
  final int number;
  final bool last;
  final int totalElements;

  const PaginaReservas({
    required this.content,
    required this.totalPages,
    required this.number,
    required this.last,
    required this.totalElements,
  });

  factory PaginaReservas.fromJson(Map<String, dynamic> json) {
    return PaginaReservas(
      content: (json['content'] as List<dynamic>)
          .map((e) => Reserva.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      totalPages: (json['totalPages'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
    );
  }
}
