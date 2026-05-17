import 'dart:async';

import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/models/chatbot.dart';

class RepoChatbot {
  RepoChatbot(this._api);

  final CitariaApi _api;

  Future<Chatbot> preguntar(String pregunta, String token) async {
    try {
      final Object? json = await _api.post(
        '/api/chatbot',
        cuerpo: Chatbot(pregunta: pregunta).toJson(),
        token: token,
      );
      return Chatbot.fromJson(json as Map<String, dynamic>);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('$e');
    }
  }
}
