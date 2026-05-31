import 'package:flutter/services.dart';

/// Validadores e inputFormatters reutilizables para los formularios.
///
/// Estrategia de defensa en profundidad: los [TextInputFormatter] bloquean
/// los caracteres no permitidos al teclear o pegar, y los validadores
/// comprueban obligatoriedad y longitud al guardar.
class Validadores {
  Validadores._();

  // Formatters: bloqueo al teclear

  /// Nombres de persona: solo letras (con acentos y ñ) y espacios.
  static final List<TextInputFormatter> nombrePersona = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]')),
  ];

  /// Nombres de catálogo (servicio, categoría, habilidad):
  /// letras, números, espacios y signos básicos.
  static final List<TextInputFormatter> nombreCatalogo = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ .,&()\-']"),
    ),
  ];

  /// Teléfono: dígitos, el signo + y espacios.
  static final List<TextInputFormatter> telefono = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
  ];

  /// Precio: dígitos y separador decimal (coma o punto).
  static final List<TextInputFormatter> precio = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  ];

  /// Documento de identidad: alfanumérico, sin símbolos ni espacios.
  static final List<TextInputFormatter> dni = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ];

  // Validadores: comprobación al guardar

  static String? nombrePersonaValidador(
    String? valor, {
    String campo = 'El nombre',
    int min = 2,
    int max = 50,
    bool obligatorio = true,
  }) {
    final String t = valor?.trim() ?? '';
    if (t.isEmpty) {
      return obligatorio ? '$campo es obligatorio' : null;
    }
    if (t.length < min) return '$campo debe tener al menos $min caracteres';
    if (t.length > max) return '$campo no puede superar los $max caracteres';
    return null;
  }

  static String? telefonoValidador(
    String? valor, {
    bool obligatorio = false,
    int min = 9,
    int max = 15,
  }) {
    final String t = valor?.trim() ?? '';
    if (t.isEmpty) return obligatorio ? 'El teléfono es obligatorio' : null;
    if (t.length < min) {
      return 'El teléfono debe tener al menos $min caracteres';
    }
    if (t.length > max) {
      return 'El teléfono no puede superar los $max caracteres';
    }
    return null;
  }

  static String? emailValidador(String? valor, {bool obligatorio = false}) {
    final String t = valor?.trim() ?? '';
    if (t.isEmpty) return obligatorio ? 'El email es obligatorio' : null;
    final RegExp formato = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!formato.hasMatch(t)) return 'El email no tiene un formato válido';
    return null;
  }

  static String? dniValidador(String? valor, {int max = 9}) {
    final String t = valor?.trim() ?? '';
    if (t.isEmpty) return null;
    if (t.length > max) {
      return 'El documento no puede superar los $max caracteres';
    }
    return null;
  }

  static String? precioValidador(String? valor) {
    final String t = valor?.trim().replaceAll(',', '.') ?? '';
    final double? p = double.tryParse(t);
    if (p == null || p <= 0) return 'Introduce un precio válido';
    return null;
  }

  static String? obligatorioValidador(String? valor, {String campo = 'El nombre'}) {
    return (valor == null || valor.trim().isEmpty)
        ? '$campo es obligatorio'
        : null;
  }
}
