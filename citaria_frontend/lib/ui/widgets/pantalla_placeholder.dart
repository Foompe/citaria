import 'package:flutter/material.dart';

/// Pantalla provisional usada por todas las rutas.
class PantallaPlaceholder extends StatelessWidget {
  const PantallaPlaceholder({super.key, required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: Text(nombre, style: Theme.of(context).textTheme.displaySmall),
      ),
    );
  }
}