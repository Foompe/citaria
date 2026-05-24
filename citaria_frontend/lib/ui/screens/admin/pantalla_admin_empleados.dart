import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_empleados.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P28 — Listado de empleados del área admin protegida por PIN.
class PantallaAdminEmpleados extends StatefulWidget {
  const PantallaAdminEmpleados({super.key});

  @override
  State<PantallaAdminEmpleados> createState() => _PantallaAdminEmpleadosState();
}

class _PantallaAdminEmpleadosState extends State<PantallaAdminEmpleados> {
  late final ViewModelAdminEmpleados _viewModel;
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminEmpleados(
      repoEmpleados: context.read<RepoEmpleados>(),
      repoCatalogo: context.read<RepoCatalogo>(),
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarEmpleados();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _irANuevoEmpleado() async {
    final bool? creado = await GestorNavegacion.irAAdminNuevoEmpleado(context);
    if (creado == true && mounted) {
      _viewModel.refrescar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.mas,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.person_add_outlined,
        tooltip: 'Nuevo empleado',
        heroTag: 'fab-admin-empleados-nuevo',
        onPressed: _irANuevoEmpleado,
      ),

      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Empleados'),
          ],
          body: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) {
          final empleados = _viewModel.empleados;
          return RefreshIndicator(
            onRefresh: _viewModel.refrescar,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.padX,
                vertical: 12,
              ),
              children: [
                _CampoBusquedaEmpleados(
                  controller: _busquedaCtrl,
                  onChanged: _viewModel.buscar,
                ),
                const SizedBox(height: 12),
                if (_viewModel.error != null)
                  _EstadoEmpleados(
                    icono: Icons.error_outline,
                    titulo: 'No se pudieron cargar los empleados',
                    mensaje: _viewModel.error!,
                    accion: 'Reintentar',
                    onPressed: _viewModel.refrescar,
                  )
                else if (_viewModel.cargando && empleados.isEmpty)
                  const _CargaEmpleados()
                else if (empleados.isEmpty)
                  _EstadoEmpleados(
                    icono: Icons.people_outline,
                    titulo: _viewModel.busqueda.trim().isEmpty
                        ? 'Aún no hay empleados'
                        : 'Sin resultados',
                    mensaje: _viewModel.busqueda.trim().isEmpty
                        ? 'Cuando se creen empleados aparecerán aquí.'
                        : 'Prueba con otro nombre, email o teléfono.',
                  )
                else
                  for (final empleado in empleados)
                    _TarjetaEmpleado(
                      empleado: empleado,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      espaciado: espaciado,
                    ),
              ],
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta de empleado ───────────────────────────────────────────────────────

class _TarjetaEmpleado extends StatelessWidget {
  const _TarjetaEmpleado({
    required this.empleado,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final DtoEmpleadoAdmin empleado;
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
        onTap: () =>
            GestorNavegacion.irAAdminDetalleEmpleado(context, '${empleado.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarFallbackCitaria(
                texto: empleado.nombreCompleto,
                imagenUrl: empleado.fotoUrl,
                tamano: 52,
                radio: 26,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleado.nombreCompleto,
                      style: textTheme.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      empleado.resumen,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (ctx) {
                        final estados =
                            Theme.of(ctx).extension<EstadosReservaCitaria>()!;
                        final colores = empleado.activo
                            ? estados.confirmada
                            : estados.completada;
                        final espaciadoCtx =
                            Theme.of(ctx).extension<EspaciadoCitaria>()!;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colores.fondo,
                            borderRadius: espaciadoCtx.radioPill,
                          ),
                          child: Text(
                            empleado.estado,
                            style: textTheme.labelSmall?.copyWith(
                              color: colores.texto,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Semantics(
                label: 'Ver detalle de ${empleado.nombreCompleto}',
                child: Icon(Icons.chevron_right, color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoBusquedaEmpleados extends StatelessWidget {
  const _CampoBusquedaEmpleados({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Buscar empleado',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class _CargaEmpleados extends StatelessWidget {
  const _CargaEmpleados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EstadoEmpleados extends StatelessWidget {
  const _EstadoEmpleados({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.onPressed,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final String? accion;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 40, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(titulo, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            mensaje,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          if (accion != null && onPressed != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onPressed, child: Text(accion!)),
          ],
        ],
      ),
    );
  }
}
