import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/aviso_error.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/campo_formulario.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';
import 'package:citaria_frontend/ui/widgets/seccion_horario_semanal.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_empleados.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P29 — Formulario de alta de nuevo empleado.
class PantallaAdminNuevoEmpleado extends StatefulWidget {
  const PantallaAdminNuevoEmpleado({super.key});

  @override
  State<PantallaAdminNuevoEmpleado> createState() =>
      _PantallaAdminNuevoEmpleadoState();
}

class _PantallaAdminNuevoEmpleadoState
    extends State<PantallaAdminNuevoEmpleado> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlApellidos = TextEditingController();
  final _ctrlEmail = TextEditingController();
  final _ctrlTelefono = TextEditingController();
  final Set<int> _skillsSeleccionadas = <int>{};
  late final ViewModelAdminEmpleados _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminEmpleados(
      repoEmpleados: context.read<RepoEmpleados>(),
      repoCatalogo: context.read<RepoCatalogo>(),
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarFormularioNuevoEmpleado();
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlApellidos.dispose();
    _ctrlEmail.dispose();
    _ctrlTelefono.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _crearEmpleado() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final empleado = await _viewModel.crearEmpleado(
      nombre: _ctrlNombre.text,
      apellidos: _ctrlApellidos.text,
      email: _ctrlEmail.text,
      telefono: _ctrlTelefono.text,
      skillIds: _skillsSeleccionadas,
    );

    if (!mounted) {
      return;
    }

    if (empleado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear el empleado.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Empleado creado')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminEmpleados>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminEmpleados>(
        builder: (context, vmEmpleados, _) => _ContenidoNuevoEmpleado(
          formKey: _formKey,
          ctrlNombre: _ctrlNombre,
          ctrlApellidos: _ctrlApellidos,
          ctrlEmail: _ctrlEmail,
          ctrlTelefono: _ctrlTelefono,
          skillsSeleccionadas: _skillsSeleccionadas,
          vmEmpleados: vmEmpleados,
          onCrear: _crearEmpleado,
          onSkillTap: _alternarSkill,
        ),
      ),
    );
  }

  void _alternarSkill(int id) {
    setState(() {
      if (_skillsSeleccionadas.contains(id)) {
        _skillsSeleccionadas.remove(id);
      } else {
        _skillsSeleccionadas.add(id);
      }
    });
  }
}

class _ContenidoNuevoEmpleado extends StatelessWidget {
  const _ContenidoNuevoEmpleado({
    required this.formKey,
    required this.ctrlNombre,
    required this.ctrlApellidos,
    required this.ctrlEmail,
    required this.ctrlTelefono,
    required this.skillsSeleccionadas,
    required this.vmEmpleados,
    required this.onCrear,
    required this.onSkillTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlApellidos;
  final TextEditingController ctrlEmail;
  final TextEditingController ctrlTelefono;
  final Set<int> skillsSeleccionadas;
  final ViewModelAdminEmpleados vmEmpleados;
  final VoidCallback onCrear;
  final ValueChanged<int> onSkillTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool cargandoInicial =
        vmEmpleados.cargando &&
        vmEmpleados.skillsDisponibles.isEmpty &&
        vmEmpleados.horariosNuevo.isEmpty;
    final bool formularioListo = vmEmpleados.horariosNuevo.isNotEmpty;

    return Scaffold(
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: vmEmpleados.cargando || !formularioListo
                ? null
                : onCrear,
            child: vmEmpleados.cargando && !cargandoInicial
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear empleado'),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(
              titulo: 'Nuevo empleado',
              mostrarAtras: true,
            ),
          ],
          body: cargandoInicial
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: formKey,
                  child: ListView(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  24,
                  espaciado.padX,
                  120,
                ),
                children: [
                  if (vmEmpleados.error != null) ...[
                    AvisoError(
                      mensaje: vmEmpleados.error!,
                      onReintentar: vmEmpleados.cargarFormularioNuevoEmpleado,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(child: _PlaceholderFoto(colorScheme: colorScheme)),
                  const SizedBox(height: 28),
                  CampoFormulario(
                    controller: ctrlNombre,
                    etiqueta: 'Nombre *',
                    validador: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'El nombre es obligatorio';
                      if (t.length < 2) return 'El nombre debe tener al menos 2 caracteres';
                      if (t.length > 50) return 'El nombre no puede superar los 50 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: ctrlApellidos,
                    etiqueta: 'Apellidos *',
                    validador: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Los apellidos son obligatorios';
                      if (t.length > 100) return 'Los apellidos no pueden superar los 100 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: ctrlEmail,
                    etiqueta: 'Email',
                    teclado: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: ctrlTelefono,
                    etiqueta: 'Teléfono',
                    teclado: TextInputType.phone,
                    validador: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      if (t.length < 9) return 'El teléfono debe tener al menos 9 caracteres';
                      if (t.length > 15) return 'El teléfono no puede superar los 15 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SeccionHorarioSemanal(
                    filas: [
                      for (int i = 0; i < vmEmpleados.horariosNuevo.length; i++)
                        FilaDiaHorario(
                          dia: vmEmpleados.horariosNuevo[i].dia,
                          activo: vmEmpleados.horariosNuevo[i].activo,
                          horario: vmEmpleados.horariosNuevo[i].horario,
                          onChanged: (v) =>
                              vmEmpleados.alternarHorarioNuevo(i, v),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'SKILLS',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (vmEmpleados.skillsDisponibles.isEmpty)
                    Text(
                      'Sin skills disponibles',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in vmEmpleados.skillsDisponibles)
                          ChipSkill(
                            etiqueta: skill.nombre,
                            seleccionado: skillsSeleccionadas.contains(
                              skill.id,
                            ),
                            onTap: () => onSkillTap(skill.id),
                          ),
                      ],
                    ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary,
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: colorScheme.onPrimary, size: 16),
          ),
        ),
      ],
    );
  }
}

