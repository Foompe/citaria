import 'package:flutter/material.dart';

/// Pantalla de estado centrado con mensaje y botón de acción.
///
/// Usado para estados de error, carga vacía o recurso no encontrado.
class EstadoCentrado extends StatelessWidget {
  const EstadoCentrado({
    super.key,
    required this.mensaje,
    required this.accionTexto,
    required this.onAccion,
  });

  final String mensaje;
  final String accionTexto;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAccion, child: Text(accionTexto)),
          ],
        ),
      ),
    );
  }
}
