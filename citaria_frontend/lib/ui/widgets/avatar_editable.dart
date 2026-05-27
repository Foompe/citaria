import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:flutter/material.dart';

class AvatarEditable extends StatelessWidget {
  const AvatarEditable({
    super.key,
    required this.texto,
    this.fotoUrl,
    this.tamano = 72.0,
    this.radio = 36.0,
    required this.cargando,
    required this.onEditar,
  });

  final String texto;
  final String? fotoUrl;
  final double tamano;
  final double radio;
  final bool cargando;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        AvatarFallbackCitaria(
          texto: texto,
          imagenUrl: fotoUrl,
          tamano: tamano,
          radio: radio,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Semantics(
            label: 'Editar foto',
            button: true,
            child: GestureDetector(
              onTap: cargando ? null : onEditar,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cargando ? colorScheme.outline : colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
