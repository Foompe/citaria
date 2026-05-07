import 'package:flutter/material.dart';

class ItemBarraNavegacionCitaria {
  const ItemBarraNavegacionCitaria({
    required this.icono,
    required this.label,
  });

  final IconData icono;
  final String label;
}

class BarraNavegacionCitaria extends StatelessWidget {
  const BarraNavegacionCitaria({
    super.key,
    required this.indiceActivo,
    required this.items,
    required this.onTap,
  });

  final int indiceActivo;
  final List<ItemBarraNavegacionCitaria> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _ItemBarraNavegacion(
                    item: items[i],
                    seleccionado: i == indiceActivo,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemBarraNavegacion extends StatelessWidget {
  const _ItemBarraNavegacion({
    required this.item,
    required this.seleccionado,
    required this.onTap,
  });

  final ItemBarraNavegacionCitaria item;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final color = seleccionado ? colorScheme.primary : colorScheme.outline;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: seleccionado
                ? Icon(
                    item.icono,
                    key: const ValueKey('icono-activo'),
                    color: color,
                    size: 24,
                  )
                : Column(
                    key: const ValueKey('icono-label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icono,
                        color: color,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
