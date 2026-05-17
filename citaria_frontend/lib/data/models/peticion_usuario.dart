import 'package:citaria_frontend/data/enums/rol_usuario.dart';

class PeticionUsuario {
  final String email;
  final String? password;
  final RolUsuario rol;
  final bool? activo;
  final int? clienteId;
  final int? empleadoId;

  const PeticionUsuario({
    required this.email,
    this.password,
    required this.rol,
    this.activo,
    this.clienteId,
    this.empleadoId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'rol': rol.toJson(),
      'activo': activo,
      'clienteId': clienteId,
      'empleadoId': empleadoId,
    };
  }
}
