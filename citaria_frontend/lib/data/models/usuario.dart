import 'package:citaria_frontend/data/enums/rol_usuario.dart';

class Usuario {
  final int? id;
  final int? organizacionId;
  final String email;
  final RolUsuario rol;
  final bool? activo;
  final bool? emailVerificado;
  final DateTime? ultimoAcceso;
  final int? clienteId;
  final int? empleadoId;

  const Usuario({
    this.id,
    this.organizacionId,
    required this.email,
    required this.rol,
    this.activo,
    this.emailVerificado,
    this.ultimoAcceso,
    this.clienteId,
    this.empleadoId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      organizacionId: json['organizacionId'] == null
          ? null
          : (json['organizacionId'] as num).toInt(),
      email: json['email'] as String,
      rol: RolUsuario.fromJson(json['rol'] as String),
      activo: json['activo'] as bool?,
      emailVerificado: json['emailVerificado'] as bool?,
      ultimoAcceso: json['ultimoAcceso'] == null
          ? null
          : DateTime.parse(json['ultimoAcceso'] as String),
      clienteId: json['clienteId'] == null
          ? null
          : (json['clienteId'] as num).toInt(),
      empleadoId: json['empleadoId'] == null
          ? null
          : (json['empleadoId'] as num).toInt(),
    );
  }
}
