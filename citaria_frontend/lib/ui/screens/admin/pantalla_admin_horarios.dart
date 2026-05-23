import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Añadir cierre se implementará en 7B.'),
                ),
              );
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
            child: AbsorbPointer(
              child: Column(
                children: [
                  for (int i = 0; i < vmHorarios.horarios.length; i++) ...[
                    FilaDiaHorario(
                      dia: vmHorarios.horarios[i].dia,
                      activo: vmHorarios.horarios[i].activo,
                      horario: vmHorarios.horarios[i].horario,
                      onChanged: (_) {},
                    ),
                    if (i < vmHorarios.horarios.length - 1)
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  ],
                ],
              ),
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
