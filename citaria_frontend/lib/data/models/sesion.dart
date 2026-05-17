import 'package:citaria_frontend/data/enums/rol_usuario.dart';

class Sesion {
  final String token;
  final String email;
  final RolUsuario rol;
  final int organizacionId;
  final int? clienteId;
  final int? empleadoId;

  const Sesion({
    required this.token,
    required this.email,
    required this.rol,
    required this.organizacionId,
    this.clienteId,
    this.empleadoId,
  });
}
