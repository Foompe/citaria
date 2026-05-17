import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/disponibilidad.dart';

class RepoDisponibilidad {
  RepoDisponibilidad(this._api);

  final CitariaApi _api;

  Future<Disponibilidad> obtener(
    DateTime fecha,
    List<int> servicioIds,
    String token, {
    int? empleadoId,
  }) async {
    try {
      final List<String> params = <String>[
        'fecha=${_formatearFecha(fecha)}',
        'servicioIds=${servicioIds.join(',')}',
        if (empleadoId != null) 'empleadoId=$empleadoId',
      ];
      final String ruta = '/api/disponibilidad?${params.join('&')}';
      final Object? json = await _api.get(ruta, token: token);
      return Disponibilidad.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }
}
