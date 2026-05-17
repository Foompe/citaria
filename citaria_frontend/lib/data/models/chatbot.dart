class Chatbot {
  final String pregunta;
  final String? respuesta;

  const Chatbot({required this.pregunta, this.respuesta});

  factory Chatbot.fromJson(Map<String, dynamic> json) {
    return Chatbot(
      pregunta: json['pregunta'] as String,
      respuesta: json['respuesta'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'pregunta': pregunta};
  }
}
