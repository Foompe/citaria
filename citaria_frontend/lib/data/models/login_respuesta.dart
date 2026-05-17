class LoginRespuesta {
  final String token;

  const LoginRespuesta({required this.token});

  factory LoginRespuesta.fromJson(Map<String, dynamic> json) {
    return LoginRespuesta(token: json['token'] as String);
  }
}
