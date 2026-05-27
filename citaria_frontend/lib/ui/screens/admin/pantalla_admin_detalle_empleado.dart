import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/ui/widgets/avatar_editable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/theme/extension_estados.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
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
      repoCatalogo: context.read<RepoCatalogo>(),
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
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
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    final String? nombreRuta = settings?.name;
    if (nombreRuta == null) return null;
    return int.tryParse(nombreRuta.split('/').last);
  }
}

// ── Contenido ─────────────────────────────────────────────────────────────────

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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Empleado', mostrarAtras: true),
          ],
          body: SafeArea(
            top: false,
            child: _CuerpoDetalleEmpleado(
              empleadoId: empleadoId,
              detalle: detalle,
              vmEmpleados: vmEmpleados,
              tabController: tabController,
            ),
          ),
        ),
      ),
    );
  }
}

class _CuerpoDetalleEmpleado extends StatelessWidget {
  const _CuerpoDetalleEmpleado({
    required this.empleadoId,
    required this.detalle,
    required this.vmEmpleados,
    required this.tabController,
  });

  final int? empleadoId;
  final DtoDetalleEmpleadoAdmin? detalle;
  final ViewModelAdminEmpleados vmEmpleados;
  final TabController tabController;

  Future<void> _editarFoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null || !context.mounted) return;

    final List<int> bytes = await imagen.readAsBytes();
    if (!context.mounted) return;
    final bool ok = await vmEmpleados.subirFoto(
      id: empleadoId!,
      bytes: bytes,
      nombreFichero: imagen.name,
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vmEmpleados.error ?? 'No se pudo subir la foto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    if (empleadoId == null) {
      return EstadoCentrado(
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
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vmEmpleados.cargarDetalleEmpleado(empleadoId!),
      );
    }

    final DtoDetalleEmpleadoAdmin? empleado = detalle;
    if (empleado == null) {
      return EstadoCentrado(
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
              AvatarEditable(
                texto: empleado.nombreCompleto,
                fotoUrl: empleado.fotoUrl,
                cargando: vmEmpleados.cargando,
                onEditar: () => _editarFoto(context),
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
              _TabDatos(empleadoId: empleadoId!, empleado: empleado),
              _TabHorarios(empleadoId: empleadoId!),
              _TabSkills(empleadoId: empleadoId!),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab Datos ─────────────────────────────────────────────────────────────────

enum _CampoEmpleado { nombre, apellidos, email, telefono }

class _TabDatos extends StatefulWidget {
  const _TabDatos({required this.empleadoId, required this.empleado});

  final int empleadoId;
  final DtoDetalleEmpleadoAdmin empleado;

  @override
  State<_TabDatos> createState() => _TabDatosState();
}

class _TabDatosState extends State<_TabDatos> {
  _CampoEmpleado? _campoEnEdicion;
  final TextEditingController _controlador = TextEditingController();

  static String _raw(String dtoValue, String fallback) =>
      dtoValue == fallback ? '' : dtoValue;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _editarCampo(_CampoEmpleado campo, String valorOriginal) {
    setState(() {
      _campoEnEdicion = campo;
      _controlador.text = valorOriginal;
      _controlador.selection = TextSelection.fromPosition(
        TextPosition(offset: _controlador.text.length),
      );
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _campoEnEdicion = null;
      _controlador.clear();
    });
  }

  Future<void> _guardarCampo(
    BuildContext context,
    ViewModelAdminEmpleados vm,
  ) async {
    final _CampoEmpleado? campo = _campoEnEdicion;
    if (campo == null) return;

    final String valor = _controlador.text.trim();
    if (campo == _CampoEmpleado.nombre && valor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio.')),
      );
      return;
    }

    final e = widget.empleado;
    final bool ok = await vm.actualizarEmpleado(
      id: widget.empleadoId,
      nombre: campo == _CampoEmpleado.nombre ? valor : e.nombre,
      apellidos: campo == _CampoEmpleado.apellidos
          ? valor
          : _raw(e.apellidos, 'Sin apellidos'),
      email:
          campo == _CampoEmpleado.email ? valor : _raw(e.email, 'Sin email'),
      telefono: campo == _CampoEmpleado.telefono
          ? valor
          : _raw(e.telefono, 'Sin teléfono'),
    );

    if (!context.mounted) return;
    if (ok) {
      _cancelarEdicion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo guardar.')),
      );
    }
  }

  Future<void> _cambiarEstado(
    BuildContext context,
    ViewModelAdminEmpleados vm,
  ) async {
    final bool nuevaActivo = !widget.empleado.activo;
    final bool ok = await vm.cambiarEstadoEmpleado(
      widget.empleadoId,
      activo: nuevaActivo,
    );
    if (!context.mounted) return;
    if (ok) {
      if (!nuevaActivo) Navigator.maybePop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo cambiar el estado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModelAdminEmpleados>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final bool cargando = vm.cargando;
    final e = widget.empleado;

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 24),
      children: [
        Text(
          'DATOS',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: Column(
            children: [
              _FilaDatoEmpleado(
                icono: Icons.person_outline,
                label: 'Nombre',
                valor: e.nombre,
                campo: _CampoEmpleado.nombre,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () =>
                    _editarCampo(_CampoEmpleado.nombre, e.nombre),
                onGuardar: () => _guardarCampo(context, vm),
                onCancelar: _cancelarEdicion,
              ),
              const _DivisorEmpleado(),
              _FilaDatoEmpleado(
                icono: Icons.group_outlined,
                label: 'Apellidos',
                valor: e.apellidos,
                campo: _CampoEmpleado.apellidos,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(
                  _CampoEmpleado.apellidos,
                  _raw(e.apellidos, 'Sin apellidos'),
                ),
                onGuardar: () => _guardarCampo(context, vm),
                onCancelar: _cancelarEdicion,
              ),
              const _DivisorEmpleado(),
              _FilaDatoEmpleado(
                icono: Icons.email_outlined,
                label: 'Email',
                valor: e.email,
                campo: _CampoEmpleado.email,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(
                  _CampoEmpleado.email,
                  _raw(e.email, 'Sin email'),
                ),
                onGuardar: () => _guardarCampo(context, vm),
                onCancelar: _cancelarEdicion,
              ),
              const _DivisorEmpleado(),
              _FilaDatoEmpleado(
                icono: Icons.phone_outlined,
                label: 'Teléfono',
                valor: e.telefono,
                campo: _CampoEmpleado.telefono,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(
                  _CampoEmpleado.telefono,
                  _raw(e.telefono, 'Sin teléfono'),
                ),
                onGuardar: () => _guardarCampo(context, vm),
                onCancelar: _cancelarEdicion,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                e.activo ? colorScheme.error : colorScheme.primary,
            side: BorderSide(
              color: e.activo ? colorScheme.error : colorScheme.primary,
            ),
          ),
          onPressed: cargando ? null : () => _cambiarEstado(context, vm),
          child: Text(e.activo ? 'Dar de baja' : 'Reactivar empleado'),
        ),
      ],
    );
  }
}

// ── Tab Horarios ──────────────────────────────────────────────────────────────

class _TabHorarios extends StatefulWidget {
  const _TabHorarios({required this.empleadoId});

  final int empleadoId;

  @override
  State<_TabHorarios> createState() => _TabHorariosState();
}

class _TabHorariosState extends State<_TabHorarios> {
  Future<void> _editarHora(
    BuildContext context,
    ViewModelAdminEmpleados vm,
    DtoHorarioEmpleadoAdmin horario,
  ) async {
    final List<String> partesInicio = horario.horaInicio.split(':');
    final List<String> partesFin = horario.horaFin.split(':');

    final TimeOfDay inicioActual = TimeOfDay(
      hour: int.tryParse(partesInicio.elementAtOrNull(0) ?? '') ?? 9,
      minute: int.tryParse(partesInicio.elementAtOrNull(1) ?? '') ?? 0,
    );
    final TimeOfDay finActual = TimeOfDay(
      hour: int.tryParse(partesFin.elementAtOrNull(0) ?? '') ?? 18,
      minute: int.tryParse(partesFin.elementAtOrNull(1) ?? '') ?? 0,
    );

    final TimeOfDay? inicio = await showTimePicker(
      context: context,
      initialTime: inicioActual,
      helpText: 'Hora de inicio',
    );
    if (inicio == null || !context.mounted) return;

    final TimeOfDay? fin = await showTimePicker(
      context: context,
      initialTime: finActual,
      helpText: 'Hora de fin',
    );
    if (fin == null || !context.mounted) return;

    final String horaInicio =
        '${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}';
    final String horaFin =
        '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}';

    final bool ok = await vm.guardarHorario(
      empleadoId: widget.empleadoId,
      horario: horario,
      activo: horario.activo,
      horaInicio: horaInicio,
      horaFin: horaFin,
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo guardar el horario.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModelAdminEmpleados>();
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final horarios = vm.horarios;

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: Column(
            children: [
              for (int i = 0; i < horarios.length; i++) ...[
                _FilaHorarioEditable(
                  horario: horarios[i],
                  guardando: vm.cargando,
                  onToggle: (activo) => vm.guardarHorario(
                    empleadoId: widget.empleadoId,
                    horario: horarios[i],
                    activo: activo,
                    horaInicio: horarios[i].horaInicio,
                    horaFin: horarios[i].horaFin,
                  ),
                  onEditarHora: () => _editarHora(context, vm, horarios[i]),
                ),
                if (i < horarios.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaHorarioEditable extends StatelessWidget {
  const _FilaHorarioEditable({
    required this.horario,
    required this.guardando,
    required this.onToggle,
    required this.onEditarHora,
  });

  final DtoHorarioEmpleadoAdmin horario;
  final bool guardando;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEditarHora;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Switch(
            value: horario.activo,
            onChanged: guardando ? null : onToggle,
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(horario.dia, style: textTheme.bodyLarge)),
          if (horario.activo)
            TextButton(
              onPressed: guardando ? null : onEditarHora,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(horario.horario, style: textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Cerrado',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tab Skills ────────────────────────────────────────────────────────────────

class _TabSkills extends StatefulWidget {
  const _TabSkills({required this.empleadoId});

  final int empleadoId;

  @override
  State<_TabSkills> createState() => _TabSkillsState();
}

class _TabSkillsState extends State<_TabSkills> {
  Future<void> _mostrarDialogoAgregarSkill(
    BuildContext context,
    ViewModelAdminEmpleados vm,
  ) async {
    final List<DtoSkillDisponibleEmpleadoAdmin> disponibles = vm.skillsDisponibles
        .where((s) => vm.skills.every((a) => a.id != s.id))
        .toList(growable: false);

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más skills disponibles para asignar.'),
        ),
      );
      return;
    }

    final int? skillId = await showDialog<int>(
      context: context,
      builder: (ctx) => _DialogoSeleccionarSkill(disponibles: disponibles),
    );

    if (skillId == null || !context.mounted) return;

    final bool ok = await vm.asignarSkillDetalle(
      empleadoId: widget.empleadoId,
      skillId: skillId,
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error ?? 'No se pudo asignar el skill.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViewModelAdminEmpleados>();
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final skills = vm.skills;

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Row(
          children: [
            Text(
              'SKILLS',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: vm.cargando
                  ? null
                  : () => _mostrarDialogoAgregarSkill(context, vm),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Añadir'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (skills.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                'Sin skills asignadas',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in skills)
                Chip(
                  label: Text(skill.nombre),
                  onDeleted: vm.cargando
                      ? null
                      : () => vm.eliminarSkillDetalle(
                            empleadoId: widget.empleadoId,
                            skillId: skill.id,
                          ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DialogoSeleccionarSkill extends StatelessWidget {
  const _DialogoSeleccionarSkill({required this.disponibles});

  final List<DtoSkillDisponibleEmpleadoAdmin> disponibles;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      title: const Text('Añadir skill'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: disponibles.length,
          itemBuilder: (ctx, i) {
            final skill = disponibles[i];
            return ListTile(
              title: Text(skill.nombre, style: textTheme.bodyLarge),
              onTap: () => Navigator.of(ctx).pop(skill.id),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

// ── Chip de estado ────────────────────────────────────────────────────────────

class _ChipEstadoEmpleado extends StatelessWidget {
  const _ChipEstadoEmpleado({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final estados = Theme.of(context).extension<EstadosReservaCitaria>()!;
    final ColoresEstado colores =
        activo ? estados.confirmada : estados.completada;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: espaciado.radioPill,
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: textTheme.labelSmall?.copyWith(color: colores.texto),
      ),
    );
  }
}

// ── Fila de dato editable ─────────────────────────────────────────────────────

class _FilaDatoEmpleado extends StatelessWidget {
  const _FilaDatoEmpleado({
    required this.icono,
    required this.label,
    required this.valor,
    this.campo,
    this.campoEnEdicion,
    this.controller,
    this.guardando = false,
    this.onEditar,
    this.onGuardar,
    this.onCancelar,
  });

  final IconData icono;
  final String label;
  final String valor;
  final _CampoEmpleado? campo;
  final _CampoEmpleado? campoEnEdicion;
  final TextEditingController? controller;
  final bool guardando;
  final VoidCallback? onEditar;
  final VoidCallback? onGuardar;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool editable = campo != null;
    final bool editando = editable && campoEnEdicion == campo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: colorScheme.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                if (editando)
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    enabled: !guardando,
                    onFieldSubmitted: (_) => onGuardar?.call(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(valor, style: textTheme.bodyLarge),
              ],
            ),
          ),
          if (editando) ...[
            IconButton(
              tooltip: 'Cancelar',
              icon: Icon(Icons.close, color: colorScheme.outline, size: 20),
              onPressed: guardando ? null : onCancelar,
            ),
            IconButton(
              tooltip: 'Guardar $label',
              icon: guardando
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.check, color: colorScheme.primary, size: 20),
              onPressed: guardando ? null : onGuardar,
            ),
          ] else if (editable)
            Semantics(
              label: 'Editar $label',
              child: IconButton(
                tooltip: 'Editar $label',
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.outline,
                  size: 18,
                ),
                onPressed: onEditar,
              ),
            ),
        ],
      ),
    );
  }
}

class _DivisorEmpleado extends StatelessWidget {
  const _DivisorEmpleado();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
    );
  }
}
