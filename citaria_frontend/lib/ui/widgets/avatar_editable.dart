import 'dart:typed_data';

import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:flutter/material.dart';

class AvatarEditable extends StatelessWidget {
  const AvatarEditable({
    super.key,
    required this.texto,
    this.fotoUrl,
    this.imagenLocalBytes,
    this.tamano = 72.0,
    this.radio = 36.0,
    required this.cargando,
    required this.onEditar,
  });

  final String texto;
  final String? fotoUrl;
  final Uint8List? imagenLocalBytes;
  final double tamano;
  final double radio;
  final bool cargando;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        imagenLocalBytes != null
            ? ClipOval(
                child: SizedBox(
                  width: tamano,
                  height: tamano,
                  child: Image.memory(imagenLocalBytes!, fit: BoxFit.cover),
                ),
              )
            : AvatarFallbackCitaria(
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
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cargando ? colorScheme.outline : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
