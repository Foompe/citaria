import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_categoria.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/fila_servicio.dart';

/// Pantalla de catálogo de servicios del área cliente (P08).
///
/// Incluye buscador, chips de categoría y lista de servicios.
///
/// HARDCODING TEMPORAL:
///   - Categorías: lista fija → TODO: cargar de API
///   - Servicios: 4 items fijos → TODO: cargar de API
class PantallaCatalogoCliente extends StatelessWidget {
  const PantallaCatalogoCliente({super.key});

  // TODO: cargar categorías de API
  static const List<String> _categorias = [
    'Todos',
    'Exterior',
    'Interior',
    'Premium',
    'Detailing',
  ];

  // TODO: cargar servicios de API
  static const List<Map<String, String>> _servicios = [
    {
      'id': 's1',
      'nombre': 'Lavado exterior',
      'descripcion':
          'Limpieza completa de carrocería con productos de alta gama.',
      'duracion': '30 min',
      'precio': '15 €',
    },
    {
      'id': 's2',
      'nombre': 'Pulido completo',
      'descripcion':
          'Eliminación de arañazos y oxidación con pulidora orbital.',
      'duracion': '90 min',
      'precio': '80 €',
    },
    {
      'id': 's3',
      'nombre': 'Interior premium',
      'descripcion':
          'Aspirado, limpieza de tapicería y tratamiento de plásticos.',
      'duracion': '60 min',
      'precio': '45 €',
    },
    {
      'id': 's4',
      'nombre': 'Detailing completo',
      'descripcion':
          'Servicio integral exterior e interior con sellado de pintura.',
      'duracion': '180 min',
      'precio': '150 €',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.catalogo,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.chat_bubble_outline,
        tooltip: 'Abrir asistente',
        heroTag: 'fab-chatbot',
        onPressed: () => GestorNavegacion.irAChatbot(context),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera manual ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicios', style: textTheme.displayLarge),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar servicio…',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Chips de categoría ─────────────────────────────────────────
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                itemCount: _categorias.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) =>
                    ChipCategoria(etiqueta: _categorias[i], activo: i == 0),
              ),
            ),
            const SizedBox(height: 8),
            // ── Lista de servicios ─────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: espaciado.safeBottom),
                itemCount: _servicios.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: espaciado.padX,
                  endIndent: espaciado.padX,
                  color: colorScheme.outline.withOpacity(0.2),
                ),
                itemBuilder: (context, i) {
                  final s = _servicios[i];
                  return FilaServicio(
                    nombre: s['nombre']!,
                    descripcion: s['descripcion']!,
                    duracion: s['duracion']!,
                    precio: s['precio']!,
                    onTap: () =>
                        GestorNavegacion.irADetalleServicio(context, s['id']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
