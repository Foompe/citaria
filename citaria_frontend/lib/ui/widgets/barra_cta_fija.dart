import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Barra de llamada a la acción fija en la parte inferior de la pantalla.
///
/// Se usa en el slot [Scaffold.bottomNavigationBar].
/// Usa [BottomAppBar] como raíz — único widget que garantiza constraints
/// finitos en ese slot independientemente del contenido hijo.
class BarraCtaFija extends StatelessWidget {
  const BarraCtaFija({super.key, required this.child, this.colorFondo});

  final Widget child;
  final Color? colorFondo;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorFondo ?? colorScheme.surface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                12,
                espaciado.padX,
                12,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
