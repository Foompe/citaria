/// Gestión de sesión PIN del área protegida de administración.
///
/// La sesión se activa al validar el PIN correctamente y se invalida
/// cuando el usuario navega fuera del área protegida.
///
/// Es un flag en memoria — no persiste entre reinicios de la app.
/// Una sesión activa da acceso a todas las zonas protegidas hasta
/// que se invalide explícitamente desde [GestorNavegacion].
class SesionPin {
  SesionPin._();

  static bool _validado = false;

  /// Devuelve true si el PIN fue validado y la sesión sigue activa.
  static bool get estaActiva => _validado;

  /// Activa la sesión tras una validación correcta del PIN.
  static void activar() => _validado = true;

  /// Invalida la sesión. Llamado desde [GestorNavegacion] al navegar
  /// fuera del área protegida.
  static void invalidar() => _validado = false;
}