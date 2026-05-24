import 'package:flutter/material.dart';

/// AppBar reutilizable de Citaria.
///
/// Implementa [PreferredSizeWidget] para usarse directamente como
/// [Scaffold.appBar]. Todos los valores visuales proceden del
/// [AppBarTheme] del tema — cero valores inline.
class CabeceraPantalla extends StatelessWidget implements PreferredSizeWidget {
  const CabeceraPantalla({
    super.key,
    required this.titulo,
    this.mostrarAtras = false,
    this.accionDerecha,
  });

  final String titulo;
  final bool mostrarAtras;

  /// Widget opcional situado en [AppBar.actions].
  final Widget? accionDerecha;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo, style: Theme.of(context).textTheme.displaySmall),
      automaticallyImplyLeading: false,
      leading: mostrarAtras
          ? IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: accionDerecha != null ? [accionDerecha!] : null,
    );
  }
}