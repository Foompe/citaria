import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';

/// Sección de card con título en mayúsculas y contenido hijo.
class CardSeccionCitaria extends StatelessWidget {
  const CardSeccionCitaria({
    super.key,
    required this.titulo,
    required this.child,
  });

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Card de texto con título de sección e icono opcional.
class CardTextoCitaria extends StatelessWidget {
  const CardTextoCitaria({
    super.key,
    required this.titulo,
    required this.texto,
    this.icono,
  });

  final String titulo;
  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return CardSeccionCitaria(
      titulo: titulo,
      child: icono != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, size: 18, color: colorScheme.outline),
                const SizedBox(width: 10),
                Expanded(child: Text(texto, style: textTheme.bodyLarge)),
              ],
            )
          : Text(texto, style: textTheme.bodyLarge),
    );
  }
}

/// Fila de información con icono, etiqueta y valor alineado a la derecha.
class FilaInfoCitaria extends StatelessWidget {
  const FilaInfoCitaria({
    super.key,
    required this.icono,
    required this.label,
    required this.valor,
  });

  final IconData icono;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.outline),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: textTheme.bodySmall)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valor,
            style: textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Fila con icono pequeño y texto a su derecha.
class LineaIconoCitaria extends StatelessWidget {
  const LineaIconoCitaria({
    super.key,
    required this.icono,
    required this.texto,
  });

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icono, size: 16, color: colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Chip de etiqueta pequeña (estado de línea, cantidad, etc.).
class EtiquetaDetalleCitaria extends StatelessWidget {
  const EtiquetaDetalleCitaria({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        texto,
        style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
      ),
    );
  }
}
