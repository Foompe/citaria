import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: GET /servicios

class _Servicio {
  const _Servicio({
    required this.id,
    required this.nombre,
    required this.duracion,
    required this.precio,
    required this.activo,
  });

  final String id;
  final String nombre;
  final String duracion;
  final String precio;
  final bool activo;
}

const List<_Servicio> _servicios = [
  _Servicio(
    id: 's1',
    nombre: 'Lavado Premium',
    duracion: '90 min',
    precio: '60,00 €',
    activo: true,
  ),
  _Servicio(
    id: 's2',
    nombre: 'Lavado Exterior',
    duracion: '45 min',
    precio: '15,00 €',
    activo: true,
  ),
  _Servicio(
    id: 's3',
    nombre: 'Limpieza Interior',
    duracion: '60 min',
    precio: '25,00 €',
    activo: true,
  ),
  _Servicio(
    id: 's4',
    nombre: 'Encerado',
    duracion: '50 min',
    precio: '50,00 €',
    activo: true,
  ),
  _Servicio(
    id: 's5',
    nombre: 'Pulido Completo',
    duracion: '180 min',
    precio: '120,00 €',
    activo: false,
  ),
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P31 — Catálogo de servicios del área admin protegida por PIN.
class PantallaAdminCatalogo extends StatefulWidget {
  const PantallaAdminCatalogo({super.key});

  @override
  State<PantallaAdminCatalogo> createState() => _PantallaAdminCatalogoState();
}

class _PantallaAdminCatalogoState extends State<PantallaAdminCatalogo>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Estado local de activación por servicio (id → activo)
  // TODO: PATCH /servicios/:id activo
  late final Map<String, bool> _activoMap;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _activoMap = {for (final s in _servicios) s.id: s.activo};
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.mas,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo servicio',
        onPressed: () => GestorNavegacion.irAAdminNuevoServicio(context),
        child: const Icon(Icons.add),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX, 16, espaciado.padX, 0,
              ),
              child: Text(
                'Catálogo',
                style: textTheme.displayLarge,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Servicios'),
                  Tab(text: 'Categorías'),
                  Tab(text: 'Skills'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab Servicios
            _TabServicios(
              servicios: _servicios,
              activoMap: _activoMap,
              onActivoChanged: (id, valor) =>
                  setState(() => _activoMap[id] = valor),
              colorScheme: colorScheme,
              textTheme: textTheme,
              espaciado: espaciado,
            ),
            // Tab Categorías
            const Center(child: Text('Próximamente')),
            // Tab Skills
            const Center(child: Text('Próximamente')),
          ],
        ),
      ),
    );
  }
}

// ── Tab Servicios ─────────────────────────────────────────────────────────────

class _TabServicios extends StatelessWidget {
  const _TabServicios({
    required this.servicios,
    required this.activoMap,
    required this.onActivoChanged,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final List<_Servicio> servicios;
  final Map<String, bool> activoMap;
  final void Function(String id, bool valor) onActivoChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: espaciado.padX,
        vertical: 12,
      ),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        final servicio = servicios[index];
        final activo = activoMap[servicio.id] ?? servicio.activo;
        return _TarjetaServicio(
          servicio: servicio,
          activo: activo,
          onActivoChanged: (v) => onActivoChanged(servicio.id, v),
          onTap: () {
            // TODO: irAAdminDetalleServicio(servicio.id) —
            // método pendiente de añadir en GestorNavegacion
            // y ruta pendiente de declarar en Rutas
          },
          colorScheme: colorScheme,
          textTheme: textTheme,
          espaciado: espaciado,
        );
      },
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({
    required this.servicio,
    required this.activo,
    required this.onActivoChanged,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final _Servicio servicio;
  final bool activo;
  final ValueChanged<bool> onActivoChanged;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: InkWell(
        borderRadius: espaciado.radioCard,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Miniatura icono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: espaciado.radioCard,
                ),
                child: Icon(
                  Icons.car_repair,
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            servicio.nombre,
                            style: textTheme.displaySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Switch(
                          value: activo,
                          onChanged: onActivoChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          servicio.duracion,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          servicio.precio,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChipEstado(
                          estado: activo
                              ? EstadoReserva.confirmada
                              : EstadoReserva.completada,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SliverPersistentHeaderDelegate para TabBar ────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}