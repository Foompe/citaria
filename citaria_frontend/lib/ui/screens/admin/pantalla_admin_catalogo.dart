import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P31 — Catálogo de servicios del área admin protegida por PIN.
class PantallaAdminCatalogo extends StatefulWidget {
  const PantallaAdminCatalogo({super.key});

  @override
  State<PantallaAdminCatalogo> createState() => _PantallaAdminCatalogoState();
}

class _PantallaAdminCatalogoState extends State<PantallaAdminCatalogo>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ViewModelAdminCatalogo _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_actualizarFab);
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarCatalogo();
  }

  @override
  void dispose() {
    _tabController.removeListener(_actualizarFab);
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _actualizarFab() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) => Scaffold(
          drawer: const MenuLateralAdmin(),
          bottomNavigationBar: const BarraNavegacionAdmin(
            seccionActiva: SeccionAdmin.mas,
          ),
          floatingActionButton: FabCitaria(
            icono: Icons.add,
            tooltip: _tooltipFab,
            heroTag: 'fab-catalogo-${_tabController.index}',
            onPressed: () => _manejarFab(context, vmCatalogo),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    espaciado.padX,
                    16,
                    espaciado.padX,
                    0,
                  ),
                  child: Text('Catálogo', style: textTheme.displayLarge),
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
            body: _CuerpoCatalogo(
              vmCatalogo: vmCatalogo,
              tabController: _tabController,
            ),
          ),
        ),
      ),
    );
  }

  String get _tooltipFab {
    return switch (_tabController.index) {
      1 => 'Nueva categoría',
      2 => 'Nueva skill',
      _ => 'Nuevo servicio',
    };
  }

  Future<void> _manejarFab(
    BuildContext context,
    ViewModelAdminCatalogo vmCatalogo,
  ) async {
    final int indice = _tabController.index;
    final Future<bool?> navegacion = switch (indice) {
      1 => GestorNavegacion.irAAdminNuevaCategoria(context),
      2 => GestorNavegacion.irAAdminNuevaSkill(context),
      _ => GestorNavegacion.irAAdminNuevoServicio(context),
    };
    final bool? creado = await navegacion;
    if (creado == true) {
      await vmCatalogo.refrescar();
    }
  }
}

class _CuerpoCatalogo extends StatelessWidget {
  const _CuerpoCatalogo({
    required this.vmCatalogo,
    required this.tabController,
  });

  final ViewModelAdminCatalogo vmCatalogo;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    if (vmCatalogo.cargando &&
        vmCatalogo.servicios.isEmpty &&
        vmCatalogo.categorias.isEmpty &&
        vmCatalogo.skills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmCatalogo.error;
    if (error != null &&
        vmCatalogo.servicios.isEmpty &&
        vmCatalogo.categorias.isEmpty &&
        vmCatalogo.skills.isEmpty) {
      return _EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmCatalogo.refrescar,
      );
    }

    return RefreshIndicator(
      onRefresh: vmCatalogo.refrescar,
      child: TabBarView(
        controller: tabController,
        children: [
          _TabServicios(servicios: vmCatalogo.servicios),
          _TabCategorias(
            categorias: vmCatalogo.categorias,
            onCategoriaTap: (categoria) async {
              final bool? actualizado =
                  await GestorNavegacion.irAAdminDetalleCategoria(
                    context,
                    categoria.id,
                  );
              if (actualizado == true) {
                await vmCatalogo.refrescar();
              }
            },
          ),
          _TabSkills(
            skills: vmCatalogo.skills,
            onSkillTap: (skill) async {
              final bool? actualizado =
                  await GestorNavegacion.irAAdminDetalleSkill(
                    context,
                    skill.id,
                  );
              if (actualizado == true) {
                await vmCatalogo.refrescar();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TabServicios extends StatelessWidget {
  const _TabServicios({required this.servicios});

  final List<DtoServicioCatalogoAdmin> servicios;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (servicios.isEmpty) {
      return const _ListaVacia(mensaje: 'Sin servicios');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        final servicio = servicios[index];
        return _TarjetaServicio(servicio: servicio);
      },
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio});

  final DtoServicioCatalogoAdmin servicio;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: espaciado.radioCard,
              ),
              child: Icon(Icons.car_repair, color: colorScheme.outline),
            ),
            const SizedBox(width: 12),
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
                      Switch(value: servicio.activo, onChanged: null),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    servicio.categoria,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        servicio.duracion,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        servicio.precio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      ChipEstado(
                        estado: servicio.activo
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
    );
  }
}

class _TabCategorias extends StatelessWidget {
  const _TabCategorias({
    required this.categorias,
    required this.onCategoriaTap,
  });

  final List<DtoCategoriaCatalogoAdmin> categorias;
  final ValueChanged<DtoCategoriaCatalogoAdmin> onCategoriaTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (categorias.isEmpty) {
      return const _ListaVacia(mensaje: 'Sin categorías');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
      itemCount: categorias.length,
      itemBuilder: (context, index) => _TarjetaSimpleCatalogo(
        nombre: categorias[index].nombre,
        onTap: () => onCategoriaTap(categorias[index]),
      ),
    );
  }
}

class _TabSkills extends StatelessWidget {
  const _TabSkills({required this.skills, required this.onSkillTap});

  final List<DtoSkillCatalogoAdmin> skills;
  final ValueChanged<DtoSkillCatalogoAdmin> onSkillTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (skills.isEmpty) {
      return const _ListaVacia(mensaje: 'Sin skills');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
      itemCount: skills.length,
      itemBuilder: (context, index) => _TarjetaSimpleCatalogo(
        nombre: skills[index].nombre,
        subtitulo: skills[index].descripcion,
        onTap: () => onSkillTap(skills[index]),
      ),
    );
  }
}

class _TarjetaSimpleCatalogo extends StatelessWidget {
  const _TarjetaSimpleCatalogo({
    required this.nombre,
    this.subtitulo,
    this.onTap,
  });

  final String nombre;
  final String? subtitulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: InkWell(
        borderRadius: espaciado.radioCard,
        onTap: onTap,
        child: ListTile(
          leading: Icon(Icons.label_outline, color: colorScheme.outline),
          title: Text(nombre, style: textTheme.displaySmall),
          subtitle: subtitulo == null ? null : Text(subtitulo!),
          trailing: onTap == null
              ? null
              : Icon(Icons.chevron_right, color: colorScheme.outline),
        ),
      ),
    );
  }
}

class _ListaVacia extends StatelessWidget {
  const _ListaVacia({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.45,
          child: Center(child: Text(mensaje)),
        ),
      ],
    );
  }
}

class _EstadoCentrado extends StatelessWidget {
  const _EstadoCentrado({
    required this.mensaje,
    required this.accionTexto,
    required this.onAccion,
  });

  final String mensaje;
  final String accionTexto;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAccion, child: Text(accionTexto)),
          ],
        ),
      ),
    );
  }
}

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
