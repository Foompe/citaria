import 'package:flutter/material.dart';

void main() {
  runApp(const CitariaApp());
}

class CitariaApp extends StatelessWidget {
  const CitariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citaria',
      home: Scaffold(
        appBar: AppBar(title: const Text('Citaria')),
        body: const Center(child: Text('App iniciada')),
      ),
    );
  }
}