import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_empleados.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P30 — Ficha de detalle de empleado.
///
/// Ruta: /admin/empleados/:id  — arguments: {'id': String}
class PantallaAdminDetalleEmpleado extends StatefulWidget {
  const PantallaAdminDetalleEmpleado({super.key, this.id});

  final int? id;

  @override
  State<PantallaAdminDetalleEmpleado> createState() =>
      _PantallaAdminDetalleEmpleadoState();
}

class _PantallaAdminDetalleEmpleadoState
    extends State<PantallaAdminDetalleEmpleado>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ViewModelAdminEmpleados _viewModel;
  int? _empleadoId;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = ViewModelAdminEmpleados(
      repoEmpleados: context.read<RepoEmpleados>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;
    final int? id = widget.id ?? _leerIdEmpleado(context);
    _empleadoId = id;
    if (id != null) {
      _viewModel.cargarDetalleEmpleado(id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminEmpleados>.value(
      value: _viewModel,
      child: _ContenidoDetalleEmpleado(
        tabController: _tabController,
        empleadoId: _empleadoId,
      ),
    );
  }

  int? _leerIdEmpleado(BuildContext context) {
    final RouteSettings? settings = ModalRoute.of(context)?.settings;
    final Object? argumentos = settings?.arguments;
    if (argumentos is Map<String, dynamic>) {
      final Object? id = argumentos['id'];
      if (id is int) {
        return id;
      }
      if (id is String) {
        return int.tryParse(id);
      }
    }

    final String? nombreRuta = settings?.name;
    if (nombreRuta == null) {
      return null;
    }
    final String ultimoSegmento = nombreRuta.split('/').last;
    return int.tryParse(ultimoSegmento);
  }
}

class _ContenidoDetalleEmpleado extends StatelessWidget {
  const _ContenidoDetalleEmpleado({
    required this.tabController,
    required this.empleadoId,
  });

  final TabController tabController;
  final int? empleadoId;

  @override
  Widget build(BuildContext context) {
    final vmEmpleados = context.watch<ViewModelAdminEmpleados>();
    final detalle = vmEmpleados.detalle;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Empleado',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Actualizar',
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: empleadoId == null
                ? null
                : () => vmEmpleados.cargarDetalleEmpleado(empleadoId!),
          ),
        ),
      ),
      body: _CuerpoDetalleEmpleado(
        empleadoId: empleadoId,
        detalle: detalle,
        horarios: vmEmpleados.horarios,
        skills: vmEmpleados.skills,
        vmEmpleados: vmEmpleados,
        tabController: tabController,
        espaciado: espaciado,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}

class _CuerpoDetalleEmpleado extends StatelessWidget {
  const _CuerpoDetalleEmpleado({
    required this.empleadoId,
    required this.detalle,
    required this.horarios,
    required this.skills,
    required this.vmEmpleados,
    required this.tabController,
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final int? empleadoId;
  final DtoDetalleEmpleadoAdmin? detalle;
  final List<DtoHorarioEmpleadoAdmin> horarios;
  final List<DtoSkillEmpleadoAdmin> skills;
  final ViewModelAdminEmpleados vmEmpleados;
  final TabController tabController;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (empleadoId == null) {
      return _EstadoCentrado(
        mensaje: 'No se ha encontrado el empleado.',
        accionTexto: 'Volver',
        onAccion: () => Navigator.maybePop(context),
      );
    }

    if (vmEmpleados.cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmEmpleados.error;
    if (error != null && detalle == null) {
      return _EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vmEmpleados.cargarDetalleEmpleado(empleadoId!),
      );
    }

    final DtoDetalleEmpleadoAdmin? empleado = detalle;
    if (empleado == null) {
      return _EstadoCentrado(
        mensaje: 'No se ha encontrado el empleado.',
        accionTexto: 'Reintentar',
        onAccion: () => vmEmpleados.cargarDetalleEmpleado(empleadoId!),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  empleado.iniciales,
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                empleado.nombreCompleto,
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              _ChipEstadoEmpleado(activo: empleado.activo),
            ],
          ),
        ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Datos'),
            Tab(text: 'Horarios'),
            Tab(text: 'Skills'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _TabDatos(
                empleado: empleado,
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
              _TabHorarios(
                horarios: horarios,
                colorScheme: colorScheme,
                textTheme: textTheme,
                espaciado: espaciado,
              ),
              _TabSkills(skills: skills),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabDatos extends StatelessWidget {
  const _TabDatos({
    required this.empleado,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final DtoDetalleEmpleadoAdmin empleado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    final campos = [
      (Icons.person_outline, 'Nombre', empleado.nombre),
      (Icons.group_outlined, 'Apellidos', empleado.apellidos),
      (Icons.email_outlined, 'Email', empleado.email),
      (Icons.phone_outlined, 'Teléfono', empleado.telefono),
      (Icons.verified_user_outlined, 'Estado', empleado.estado),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: Column(
            children: [
              for (int i = 0; i < campos.length; i++) ...[
                ListTile(
                  leading: Icon(campos[i].$1, color: colorScheme.outline),
                  title: Text(
                    campos[i].$2,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  subtitle: Text(campos[i].$3, style: textTheme.bodyLarge),
                ),
                if (i < campos.length - 1)
                  Divider(
                    height: 1,
                    indent: espaciado.padX,
                    endIndent: espaciado.padX,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TabHorarios extends StatelessWidget {
  const _TabHorarios({
    required this.horarios,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final List<DtoHorarioEmpleadoAdmin> horarios;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    if (horarios.isEmpty) {
      return const Center(child: Text('Sin horarios'));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Text(
          'HORARIO SEMANAL',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: AbsorbPointer(
            child: Column(
              children: [
                for (int i = 0; i < horarios.length; i++) ...[
                  FilaDiaHorario(
                    dia: horarios[i].dia,
                    activo: horarios[i].activo,
                    horario: horarios[i].horario,
                    onChanged: (_) {},
                  ),
                  if (i < horarios.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabSkills extends StatelessWidget {
  const _TabSkills({required this.skills});

  final List<DtoSkillEmpleadoAdmin> skills;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    if (skills.isEmpty) {
      return const Center(child: Text('Sin skills'));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in skills) EtiquetaWizard(etiqueta: skill.nombre),
          ],
        ),
      ],
    );
  }
}

class _ChipEstadoEmpleado extends StatelessWidget {
  const _ChipEstadoEmpleado({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final Color color = activo ? Colors.green.shade700 : colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: textTheme.labelSmall?.copyWith(color: color),
      ),
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
