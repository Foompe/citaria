import 'package:citaria_frontend/data/models/cliente.dart';

class PaginaClientes {
  final List<Cliente> content;
  final int totalPages;
  final int number;
  final bool last;
  final int totalElements;

  const PaginaClientes({
    required this.content,
    required this.totalPages,
    required this.number,
    required this.last,
    required this.totalElements,
  });

  factory PaginaClientes.fromJson(Map<String, dynamic> json) {
    return PaginaClientes(
      content: (json['content'] as List<dynamic>)
          .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      totalPages: (json['totalPages'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      last: json['last'] as bool,
      totalElements: (json['totalElements'] as num).toInt(),
    );
  }
}
