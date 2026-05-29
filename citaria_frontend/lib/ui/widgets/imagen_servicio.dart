import 'package:flutter/material.dart';

class ImagenServicio extends StatelessWidget {
  const ImagenServicio({super.key, this.imagenUrl, this.fit = BoxFit.cover});

  final String? imagenUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String? url = imagenUrl?.trim();
    if (url == null || url.isEmpty) {
      return const _Placeholder();
    }
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.design_services_outlined,
          color: colorScheme.onPrimary.withValues(alpha: 0.4),
          size: 40,
        ),
      ),
    );
  }
}
