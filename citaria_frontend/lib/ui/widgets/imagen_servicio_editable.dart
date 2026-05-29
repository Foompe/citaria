import 'dart:typed_data';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/imagen_servicio.dart';
import 'package:flutter/material.dart';

class ImagenServicioEditable extends StatelessWidget {
  const ImagenServicioEditable({
    super.key,
    required this.imagenUrl,
    required this.espaciado,
    required this.colorScheme,
    required this.onEditar,
    this.imagenLocalBytes,
    this.cargando = false,
  });

  final String? imagenUrl;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final VoidCallback onEditar;
  final Uint8List? imagenLocalBytes;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: espaciado.radioCard,
          child: SizedBox(
            width: 120,
            height: 120,
            child: imagenLocalBytes != null
                ? Image.memory(imagenLocalBytes!, fit: BoxFit.cover)
                : ImagenServicio(imagenUrl: imagenUrl),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onEditar,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomRight: Radius.circular(espaciado.radioCard.topRight.x),
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

