class PeticionLogin {
  final String email;
  final String password;
  final int organizacionId;

  const PeticionLogin({
    required this.email,
    required this.password,
    required this.organizacionId,
  });

  factory PeticionLogin.fromJson(Map<String, dynamic> json) {
    return PeticionLogin(
      email: json['email'] as String,
      password: json['password'] as String,
      organizacionId: (json['organizacionId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'organizacionId': organizacionId,
    };
  }
}
