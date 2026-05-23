import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Fila de servicio para [PantallaCatalogoCliente].
///
/// Muestra miniatura placeholder, nombre, descripción, duración
/// y precio. Toda la fila es tappable vía [onTap].
class FilaServicio extends StatelessWidget {
  const FilaServicio({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.duracion,
    required this.precio,
    this.imagenUrl,
    required this.onTap,
  });

  final String nombre;
  final String descripcion;
  final String duracion;
  final String precio;
  final String? imagenUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: espaciado.radioCard,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
        child: Row(
          children: [
            _MiniaturaServicio(
              imagenUrl: imagenUrl,
              radio: espaciado.radioCard,
              colorPlaceholder: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            // Información del servicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: textTheme.displaySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(duracion, style: textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text(
                        precio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _MiniaturaServicio extends StatelessWidget {
  const _MiniaturaServicio({
    required this.imagenUrl,
    required this.radio,
    required this.colorPlaceholder,
  });

  final String? imagenUrl;
  final BorderRadius radio;
  final Color colorPlaceholder;

  @override
  Widget build(BuildContext context) {
    final String? url = imagenUrl?.trim();
    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: radio,
      child: Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: colorPlaceholder, borderRadius: radio),
    );
  }
}
