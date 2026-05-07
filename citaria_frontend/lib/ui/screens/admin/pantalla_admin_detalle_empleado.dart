import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: GET /empleados/:id

class _EmpleadoDetalle {
  const _EmpleadoDetalle({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.especialidad,
    required this.email,
    required this.telefono,
    required this.activo,
    required this.skills,
  });

  final String id;
  final String nombre;
  final String apellidos;
  final String especialidad;
  final String email;
  final String telefono;
  final bool activo;
  final List<String> skills;
}

const _EmpleadoDetalle _empleadoEjemplo = _EmpleadoDetalle(
  id: 'e1',
  nombre: 'Carlos',
  apellidos: 'Martínez',
  especialidad: 'Detailer Senior',
  email: 'carlos.martinez@detailcarwash.es',
  telefono: '+34 612 000 001',
  activo: true,
  skills: ['Exterior', 'Pulido', 'Cera', 'Premium'],
);

const List<String> _diasSemana = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

// TODO: horarios reales del empleado
const List<bool> _activoInicial = [
  true, true, true, true, true, true, false,
];

const List<String> _horarioTexto = [
  '9:00 – 19:00',
  '9:00 – 19:00',
  '9:00 – 19:00',
  '9:00 – 19:00',
  '9:00 – 19:00',
  '9:00 – 14:00',
  'Cerrado',
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P30 — Ficha de detalle de empleado.
///
/// Ruta: /admin/empleados/:id  — arguments: {'id': String}
class PantallaAdminDetalleEmpleado extends StatefulWidget {
  const PantallaAdminDetalleEmpleado({super.key});

  @override
  State<PantallaAdminDetalleEmpleado> createState() =>
      _PantallaAdminDetalleEmpleadoState();
}

class _PantallaAdminDetalleEmpleadoState
    extends State<PantallaAdminDetalleEmpleado>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<bool> _diasActivos;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _diasActivos = List<bool>.from(_activoInicial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _nombreCompleto =>
      '${_empleadoEjemplo.nombre} ${_empleadoEjemplo.apellidos}';

  String get _iniciales =>
      '${_empleadoEjemplo.nombre[0]}${_empleadoEjemplo.apellidos[0]}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: 'Empleado',
        mostrarAtras: true,
        accionDerecha: Tooltip(
          message: 'Editar',
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: edición del empleado
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Cabecera centrada ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              espaciado.padX, 24, espaciado.padX, 16,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _iniciales,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _nombreCompleto,
                  style: textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: espaciado.radioPill,
                  ),
                  child: Text(
                    '● Activo',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── TabBar ────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Datos'),
              Tab(text: 'Horarios'),
              Tab(text: 'Skills'),
            ],
          ),

          // ── TabBarView ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TabDatos(
                  empleado: _empleadoEjemplo,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                _TabHorarios(
                  diasActivos: _diasActivos,
                  onDiaChanged: (i, v) =>
                      setState(() => _diasActivos[i] = v),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                _TabSkills(skills: _empleadoEjemplo.skills),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Datos ─────────────────────────────────────────────────────────────────

class _TabDatos extends StatelessWidget {
  const _TabDatos({
    required this.empleado,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final _EmpleadoDetalle empleado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    final campos = [
      (Icons.person_outline, 'Nombre',       empleado.nombre),
      (Icons.work_outline,   'Especialidad', empleado.especialidad),
      (Icons.email_outlined, 'Email',        empleado.email),
      (Icons.phone_outlined, 'Teléfono',     empleado.telefono),
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
        const SizedBox(height: 24),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          onPressed: () {
            // TODO: dar de baja empleado — PATCH /empleados/:id
          },
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }
}

// ── Tab Horarios ──────────────────────────────────────────────────────────────

class _TabHorarios extends StatelessWidget {
  const _TabHorarios({
    required this.diasActivos,
    required this.onDiaChanged,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final List<bool> diasActivos;
  final void Function(int index, bool valor) onDiaChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    // TODO: horarios reales del empleado
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
          child: Column(
            children: [
              for (int i = 0; i < _diasSemana.length; i++) ...[
                FilaDiaHorario(
                  dia: _diasSemana[i],
                  activo: diasActivos[i],
                  horario: _horarioTexto[i],
                  onChanged: (v) => onDiaChanged(i, v),
                ),
                if (i < _diasSemana.length - 1)
                  Divider(height: 1, color: colorScheme.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab Skills ────────────────────────────────────────────────────────────────

class _TabSkills extends StatelessWidget {
  const _TabSkills({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    // TODO: skills reales del empleado
    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((s) => EtiquetaWizard(etiqueta: s))
              .toList(),
        ),
      ],
    );
  }
}