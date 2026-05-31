import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de formulario estándar con estilo del tema.
///
/// Lee el radio de borde del tema.
class CampoFormulario extends StatelessWidget {
  const CampoFormulario({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.teclado,
    this.validador,
    this.formateadores,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String etiqueta;
  final TextInputType? teclado;
  final String? Function(String?)? validador;
  final List<TextInputFormatter>? formateadores;
  final TextCapitalization textCapitalization;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      validator: validador,
      inputFormatters: formateadores,
      textCapitalization: textCapitalization,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: espaciado.radioInput),
      ),
    );
  }
}
