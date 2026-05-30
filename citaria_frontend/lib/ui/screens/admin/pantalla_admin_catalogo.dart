import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/chip_activo_inactivo.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/imagen_servicio.dart';
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
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              const CabeceraTituloGrande(titulo: 'Catálogo'),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Servicios'),
                      Tab(text: 'Categorías'),
                      Tab(text: 'Habilidades'),
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
      ),
    );
  }

  String get _tooltipFab {
    return switch (_tabController.index) {
      1 => 'Nueva categoría',
      2 => 'Nueva habilidad',
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
      2 => GestorNavegacion.irAAdminNuevaHabilidad(context),
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
        vmCatalogo.habilidades.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmCatalogo.error;
    if (error != null &&
        vmCatalogo.servicios.isEmpty &&
        vmCatalogo.categorias.isEmpty &&
        vmCatalogo.habilidades.isEmpty) {
      return EstadoCentrado(
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
          _TabServicios(
            servicios: vmCatalogo.servicios,
            onServicioTap: (servicio) async {
              final bool? actualizado =
                  await GestorNavegacion.irAAdminDetalleServicio(
                    context,
                    servicio.id,
                  );
              if (actualizado == true) {
                await vmCatalogo.refrescar();
              }
            },
          ),
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
          _TabHabilidades(
            habilidades: vmCatalogo.habilidades,
            onHabilidadTap: (habilidad) async {
              final bool? actualizado =
                  await GestorNavegacion.irAAdminDetalleHabilidad(
                    context,
                    habilidad.id,
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
  const _TabServicios({required this.servicios, required this.onServicioTap});

  final List<DtoServicioCatalogoAdmin> servicios;
  final ValueChanged<DtoServicioCatalogoAdmin> onServicioTap;

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
        return _TarjetaServicio(
          servicio: servicio,
          onTap: () => onServicioTap(servicio),
        );
      },
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio, required this.onTap});

  final DtoServicioCatalogoAdmin servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String? imagenUrl = servicio.imagenUrl;

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
              ClipRRect(
                borderRadius: espaciado.radioCard,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ImagenServicio(imagenUrl: imagenUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio.nombre,
                      style: textTheme.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        ChipActivoInactivo(activo: servicio.activo),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
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
        activo: categorias[index].activo,
        onTap: () => onCategoriaTap(categorias[index]),
      ),
    );
  }
}

class _TabHabilidades extends StatelessWidget {
  const _TabHabilidades({required this.habilidades, required this.onHabilidadTap});

  final List<DtoHabilidadCatalogoAdmin> habilidades;
  final ValueChanged<DtoHabilidadCatalogoAdmin> onHabilidadTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    if (habilidades.isEmpty) {
      return const _ListaVacia(mensaje: 'Sin habilidades');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
      itemCount: habilidades.length,
      itemBuilder: (context, index) => _TarjetaSimpleCatalogo(
        nombre: habilidades[index].nombre,
        subtitulo: habilidades[index].descripcion,
        activo: habilidades[index].activo,
        onTap: () => onHabilidadTap(habilidades[index]),
      ),
    );
  }
}

class _TarjetaSimpleCatalogo extends StatelessWidget {
  const _TarjetaSimpleCatalogo({
    required this.nombre,
    this.subtitulo,
    this.activo,
    this.onTap,
  });

  final String nombre;
  final String? subtitulo;
  final bool? activo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget? subtitleWidget;
    if (activo != null) {
      subtitleWidget = Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (subtitulo != null) Text(subtitulo!),
            ChipActivoInactivo(activo: activo!),
          ],
        ),
      );
    } else if (subtitulo != null) {
      subtitleWidget = Text(subtitulo!);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: InkWell(
        borderRadius: espaciado.radioCard,
        onTap: onTap,
        child: ListTile(
          leading: Icon(Icons.label_outline, color: colorScheme.outline),
          title: Text(nombre, style: textTheme.displaySmall),
          subtitle: subtitleWidget,
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
