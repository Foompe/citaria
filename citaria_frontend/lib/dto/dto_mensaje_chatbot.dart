import 'package:flutter/foundation.dart';

@immutable
class DtoMensajeChatbot {
  const DtoMensajeChatbot({
    required this.texto,
    required this.esUsuario,
    required this.enviando,
    required this.error,
  });

  final String texto;
  final bool esUsuario;
  final bool enviando;
  final bool error;
}
