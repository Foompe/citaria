import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_categoria.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/logo_citaria.dart';

/// Pantalla de inicio del área cliente (P07).
///
/// Muestra saludo, chips de categoría, servicios destacados en
/// scroll horizontal y la próxima cita del usuario.
///
/// HARDCODING TEMPORAL:
///   - Nombre de usuario: 'Carlos' → TODO: leer de ViewModelAutenticacion
///   - Categorías: lista fija → TODO: cargar de API
///   - Servicios destacados: 3 items fijos → TODO: cargar de API
///   - Próxima cita: 1 item fijo → TODO: cargar de API
class PantallaInicioCliente extends StatelessWidget {
  const PantallaInicioCliente({super.key});

  // TODO: cargar categorías de API
  static const List<String> _categorias = [
    'Todos',
    'Exterior',
    'Interior',
    'Premium',
    'Detailing',
  ];

  // TODO: cargar servicios de API
  static const List<Map<String, String>> _serviciosDestacados = [
    {
      'id': 's1',
      'nombre': 'Lavado exterior',
      'duracion': '30 min',
      'precio': '15 €',
    },
    {
      'id': 's2',
      'nombre': 'Pulido completo',
      'duracion': '90 min',
      'precio': '80 €',
    },
    {
      'id': 's3',
      'nombre': 'Interior premium',
      'duracion': '60 min',
      'precio': '45 €',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.inicio,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.chat_bubble_outline,
        tooltip: 'Abrir asistente',
        heroTag: 'fab-chatbot',
        onPressed: () => GestorNavegacion.irAChatbot(context),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Cabecera manual ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  8,
                  espaciado.padX,
                  16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        // TODO: iniciales reales del ViewModelAutenticacion
                        'CV',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const LogoCitaria(tamano: LogoTamano.pequeno),
                    const Spacer(),
                    Semantics(
                      label: 'Notificaciones',
                      child: IconButton(
                        tooltip: 'Notificaciones',
                        icon: const Icon(Icons.notifications_none),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Saludo ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // TODO: nombre real del ViewModelAutenticacion
                      'Hola, Carlos',
                      style: textTheme.displayLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¿Qué servicio necesitas hoy?',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            // ── Chips de categoría ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
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
              ),
            ),

            // ── Servicios destacados ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: espaciado.padX,
                  right: espaciado.padX,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Servicios destacados', style: textTheme.displaySmall),
                    GestureDetector(
                      onTap: () => GestorNavegacion.irACatalogo(context),
                      child: Text(
                        'Ver todos',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                    itemCount: _serviciosDestacados.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final s = _serviciosDestacados[i];
                      return _TarjetaServicioDestacado(
                        nombre: s['nombre']!,
                        duracion: s['duracion']!,
                        precio: s['precio']!,
                        onTap: () => GestorNavegacion.irADetalleServicio(
                          context,
                          s['id']!,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Próximas citas ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  28,
                  espaciado.padX,
                  0,
                ),
                child: Text(
                  'Mis próximas citas',
                  style: textTheme.displaySmall,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  12,
                  espaciado.padX,
                  32,
                ),
                // TODO: cargar reservas de API
                child: _TarjetaProximaCita(
                  estado: EstadoReserva.confirmada,
                  nombreServicio: 'Lavado exterior',
                  meta: 'Lunes 5 may · 10:00 h',
                  precio: '15 €',
                  onTap: () =>
                      GestorNavegacion.irADetalleReservaCliente(context, 'r1'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _TarjetaServicioDestacado extends StatelessWidget {
  const _TarjetaServicioDestacado({
    required this.nombre,
    required this.duracion,
    required this.precio,
    required this.onTap,
  });

  final String nombre;
  final String duracion;
  final String precio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.85),
              colorScheme.primary.withOpacity(0.50),
            ],
          ),
          borderRadius: espaciado.radioCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              nombre,
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              duracion,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.80),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              precio,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaProximaCita extends StatelessWidget {
  const _TarjetaProximaCita({
    required this.estado,
    required this.nombreServicio,
    required this.meta,
    required this.precio,
    required this.onTap,
  });

  final EstadoReserva estado;
  final String nombreServicio;
  final String meta;
  final String precio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: espaciado.radioCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChipEstado(estado: estado),
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              const SizedBox(height: 10),
              Text(nombreServicio, style: textTheme.displaySmall),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(meta, style: textTheme.bodySmall),
                  Text(
                    precio,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
