import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_horarios.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P33 — Gestión de horarios del negocio.
class PantallaAdminHorarios extends StatefulWidget {
  const PantallaAdminHorarios({super.key});

  @override
  State<PantallaAdminHorarios> createState() => _PantallaAdminHorariosState();
}

class _PantallaAdminHorariosState extends State<PantallaAdminHorarios> {
  late final ViewModelAdminHorarios _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminHorarios(
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarHorarios();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminHorarios>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminHorarios>(
        builder: (context, vmHorarios, _) => Scaffold(
          drawer: const MenuLateralAdmin(),
          bottomNavigationBar: const BarraNavegacionAdmin(
            seccionActiva: SeccionAdmin.mas,
          ),
          appBar: const CabeceraPantalla(
            titulo: 'Horarios',
            mostrarAtras: false,
          ),
          floatingActionButton: FabCitaria(
            icono: Icons.add,
            tooltip: 'Añadir cierre',
            heroTag: 'fab-horarios-cierre',
            onPressed: () async {
              final bool? creado = await GestorNavegacion.irAAdminNuevoCierre(
                context,
              );
              if (creado == true && context.mounted) {
                await vmHorarios.refrescar();
              }
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: _CuerpoHorarios(vmHorarios: vmHorarios),
        ),
      ),
    );
  }
}

class _CuerpoHorarios extends StatelessWidget {
  const _CuerpoHorarios({required this.vmHorarios});

  final ViewModelAdminHorarios vmHorarios;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vmHorarios.cargando &&
        vmHorarios.horarios.every((horario) => !horario.activo) &&
        vmHorarios.cierres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmHorarios.error;
    if (error != null &&
        vmHorarios.horarios.every((horario) => !horario.activo) &&
        vmHorarios.cierres.isEmpty) {
      return _EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmHorarios.refrescar,
      );
    }

    return RefreshIndicator(
      onRefresh: vmHorarios.refrescar,
      child: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 120),
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
            child: Column(
              children: [
                for (int i = 0; i < vmHorarios.horarios.length; i++) ...[
                  _FilaHorarioEditable(
                    horario: vmHorarios.horarios[i],
                    deshabilitado: vmHorarios.cargando,
                    onActivoChanged: (activo) => _guardarHorario(
                      context,
                      vmHorarios,
                      vmHorarios.horarios[i],
                      activo: activo,
                    ),
                    onEditar: () => _editarHorario(
                      context,
                      vmHorarios,
                      vmHorarios.horarios[i],
                    ),
                  ),
                  if (i < vmHorarios.horarios.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'CIERRES PUNTUALES',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
            child: vmHorarios.cierres.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sin cierres programados',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < vmHorarios.cierres.length; i++) ...[
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                          title: Text(
                            vmHorarios.cierres[i].fecha,
                            style: textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            vmHorarios.cierres[i].motivo,
                            style: textTheme.bodySmall,
                          ),
                          trailing: Tooltip(
                            message: 'Eliminar cierre',
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: vmHorarios.cargando
                                  ? null
                                  : () => _confirmarEliminarCierre(
                                      context,
                                      vmHorarios,
                                      vmHorarios.cierres[i],
                                    ),
                            ),
                          ),
                        ),
                        if (i < vmHorarios.cierres.length - 1)
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarCierre(
    BuildContext context,
    ViewModelAdminHorarios vmHorarios,
    DtoCierreOrganizacionAdmin cierre,
  ) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cierre'),
        content: Text('¿Quieres eliminar el cierre del ${cierre.fecha}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    final bool eliminado = await vmHorarios.eliminarCierre(cierre.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          eliminado
              ? 'Cierre eliminado'
              : vmHorarios.error ?? 'No se pudo eliminar el cierre.',
        ),
      ),
    );
  }

  Future<void> _guardarHorario(
    BuildContext context,
    ViewModelAdminHorarios vmHorarios,
    DtoHorarioOrganizacionAdmin horario, {
    required bool activo,
  }) async {
    final bool guardado = await vmHorarios.guardarHorario(
      id: horario.id,
      diaSemana: horario.diaSemana,
      horaApertura: horario.horaApertura,
      horaCierre: horario.horaCierre,
      activo: activo,
    );

    if (!context.mounted) {
      return;
    }

    if (!guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vmHorarios.error ?? 'No se pudo actualizar el horario.',
          ),
        ),
      );
    }
  }

  Future<void> _editarHorario(
    BuildContext context,
    ViewModelAdminHorarios vmHorarios,
    DtoHorarioOrganizacionAdmin horario,
  ) async {
    final _HorarioEditado? editado = await showDialog<_HorarioEditado>(
      context: context,
      builder: (dialogContext) => _DialogoEditarHorario(horario: horario),
    );

    if (editado == null || !context.mounted) {
      return;
    }

    final bool guardado = await vmHorarios.guardarHorario(
      id: horario.id,
      diaSemana: horario.diaSemana,
      horaApertura: editado.horaApertura,
      horaCierre: editado.horaCierre,
      activo: editado.activo,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardado
              ? 'Horario actualizado'
              : vmHorarios.error ?? 'No se pudo actualizar el horario.',
        ),
      ),
    );
  }
}

class _FilaHorarioEditable extends StatelessWidget {
  const _FilaHorarioEditable({
    required this.horario,
    required this.deshabilitado,
    required this.onActivoChanged,
    required this.onEditar,
  });

  final DtoHorarioOrganizacionAdmin horario;
  final bool deshabilitado;
  final ValueChanged<bool> onActivoChanged;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 12, right: 4),
      leading: Switch(
        value: horario.activo,
        onChanged: deshabilitado ? null : onActivoChanged,
      ),
      title: Text(horario.dia, style: textTheme.bodyLarge),
      subtitle: Text(
        horario.activo ? horario.horario : 'Cerrado',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
      ),
      trailing: Tooltip(
        message: 'Editar horario',
        child: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: deshabilitado ? null : onEditar,
        ),
      ),
      onTap: deshabilitado ? null : onEditar,
    );
  }
}

class _HorarioEditado {
  const _HorarioEditado({
    required this.horaApertura,
    required this.horaCierre,
    required this.activo,
  });

  final String horaApertura;
  final String horaCierre;
  final bool activo;
}

class _DialogoEditarHorario extends StatefulWidget {
  const _DialogoEditarHorario({required this.horario});

  final DtoHorarioOrganizacionAdmin horario;

  @override
  State<_DialogoEditarHorario> createState() => _DialogoEditarHorarioState();
}

class _DialogoEditarHorarioState extends State<_DialogoEditarHorario> {
  late TimeOfDay _apertura;
  late TimeOfDay _cierre;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _apertura = _parsearHora(widget.horario.horaApertura);
    _cierre = _parsearHora(widget.horario.horaCierre);
    _activo = widget.horario.activo;
  }

  Future<void> _seleccionarApertura() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _apertura,
    );
    if (hora != null) {
      setState(() => _apertura = hora);
    }
  }

  Future<void> _seleccionarCierre() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _cierre,
    );
    if (hora != null) {
      setState(() => _cierre = hora);
    }
  }

  void _guardar() {
    if (_activo && _minutos(_cierre) <= _minutos(_apertura)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de cierre debe ser posterior a la apertura.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _HorarioEditado(
        horaApertura: _formatearHora(_apertura),
        horaCierre: _formatearHora(_cierre),
        activo: _activo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.horario.dia),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Día activo'),
            value: _activo,
            onChanged: (valor) => setState(() => _activo = valor),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Apertura'),
            subtitle: Text(_formatearHora(_apertura)),
            onTap: _seleccionarApertura,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Cierre'),
            subtitle: Text(_formatearHora(_cierre)),
            onTap: _seleccionarCierre,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }

  TimeOfDay _parsearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length < 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 9,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  int _minutos(TimeOfDay hora) => hora.hour * 60 + hora.minute;

  String _formatearHora(TimeOfDay hora) {
    final String horas = hora.hour.toString().padLeft(2, '0');
    final String minutos = hora.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
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
