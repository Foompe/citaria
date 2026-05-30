import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:flutter/material.dart';

/// Cabecera con título grande (displayLarge) reutilizable como sliver.
///
/// Diseñada para usarse dentro de [NestedScrollView.headerSliverBuilder].
/// El título se renderiza con [TextTheme.displayLarge] y se ajusta a
/// múltiples líneas si el texto es largo — sin puntos suspensivos.
class CabeceraTituloGrande extends StatelessWidget {
  const CabeceraTituloGrande({
    super.key,
    required this.titulo,
    this.mostrarAtras = false,
    this.accionDerecha,
  });

  final String titulo;
  final bool mostrarAtras;

  /// Widget opcional situado a la derecha de la fila de navegación.
  final Widget? accionDerecha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final bool tieneNavRow = mostrarAtras || accionDerecha != null;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX,
          tieneNavRow ? 4 : 12,
          espaciado.padX,
          8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tieneNavRow)
              Row(
                children: [
                  if (mostrarAtras)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Volver',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  const Spacer(),
                  ?accionDerecha,
                ],
              ),
            Text(titulo, style: textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
