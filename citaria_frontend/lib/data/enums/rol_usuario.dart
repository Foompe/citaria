enum RolUsuario {
  admin,
  empleado,
  cliente;

  factory RolUsuario.fromJson(String valor) {
    return switch (valor) {
      'ADMIN' => RolUsuario.admin,
      'EMPLEADO' => RolUsuario.empleado,
      'CLIENTE' => RolUsuario.cliente,
      _ => throw ArgumentError('RolUsuario no válido: $valor'),
    };
  }

  String toJson() {
    return switch (this) {
      RolUsuario.admin => 'ADMIN',
      RolUsuario.empleado => 'EMPLEADO',
      RolUsuario.cliente => 'CLIENTE',
    };
  }
}
