import 'package:flutter/material.dart';

class AvatarFallbackCitaria extends StatelessWidget {
  const AvatarFallbackCitaria({
    super.key,
    required this.texto,
    this.imagenAsset,
    this.imagenUrl,
    this.tamano = 44,
    this.radio = 12,
  });

  final String texto;
  final String? imagenAsset;
  final String? imagenUrl;
  final double tamano;
  final double radio;

  @override
  Widget build(BuildContext context) {
    if (imagenAsset != null && imagenAsset!.isNotEmpty) {
      return _AvatarImagenAsset(
        imagenAsset: imagenAsset!,
        textoFallback: texto,
        tamano: tamano,
        radio: radio,
      );
    }

    if (imagenUrl != null && imagenUrl!.isNotEmpty) {
      return _AvatarImagenUrl(
        imagenUrl: imagenUrl!,
        textoFallback: texto,
        tamano: tamano,
        radio: radio,
      );
    }

    return _AvatarLetra(
      texto: texto,
      tamano: tamano,
      radio: radio,
    );
  }
}

class _AvatarImagenAsset extends StatelessWidget {
  const _AvatarImagenAsset({
    required this.imagenAsset,
    required this.textoFallback,
    required this.tamano,
    required this.radio,
  });

  final String imagenAsset;
  final String textoFallback;
  final double tamano;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: tamano,
      height: tamano,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Image.asset(
        imagenAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _AvatarLetra(
          texto: textoFallback,
          tamano: tamano,
          radio: radio,
        ),
      ),
    );
  }
}

class _AvatarImagenUrl extends StatelessWidget {
  const _AvatarImagenUrl({
    required this.imagenUrl,
    required this.textoFallback,
    required this.tamano,
    required this.radio,
  });

  final String imagenUrl;
  final String textoFallback;
  final double tamano;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: tamano,
      height: tamano,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Image.network(
        imagenUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _AvatarLetra(
          texto: textoFallback,
          tamano: tamano,
          radio: radio,
        ),
      ),
    );
  }
}

class _AvatarLetra extends StatelessWidget {
  const _AvatarLetra({
    required this.texto,
    required this.tamano,
    required this.radio,
  });

  final String texto;
  final double tamano;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final color = _colorDesdeTexto(texto);
    final iniciales = _inicialesDesdeTexto(texto);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        iniciales,
        style: textTheme.displaySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _inicialesDesdeTexto(String texto) {
    final palabras = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((palabra) => palabra.isNotEmpty)
        .toList();

    if (palabras.isEmpty) return '?';

    final primera = palabras.first.characters.first.toUpperCase();

    if (palabras.length == 1) {
      return primera;
    }

    final segunda = palabras[1].characters.first.toUpperCase();

    return '$primera$segunda';
  }

  Color _colorDesdeTexto(String texto) {
    final colores = <Color>[
      const Color(0xFF2E6BFF),
      const Color(0xFF1E9E6A),
      const Color(0xFFB07A10),
      const Color(0xFFA82828),
      const Color(0xFF7B61FF),
      const Color(0xFF008C95),
    ];

    final hash = texto.codeUnits.fold<int>(
      0,
      (valor, unidad) => valor + unidad,
    );

    return colores[hash % colores.length];
  }
}
