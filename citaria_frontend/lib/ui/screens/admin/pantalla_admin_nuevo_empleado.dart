import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';

// ── Constantes de dominio ─────────────────────────────────────────────────────

const List<String> _diasSemana = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

// Estado inicial: L-V activo 9:00-19:00, Sáb activo 9:00-14:00, Dom inactivo
// TODO: horario editable con TimePicker
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

const List<String> _skillsDisponibles = [
  'Exterior', 'Interior', 'Premium', 'Detallado',
  'Cera', 'Pulido', 'Tapicería', 'Aspirado',
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P29 — Formulario de alta de nuevo empleado.
class PantallaAdminNuevoEmpleado extends StatefulWidget {
  const PantallaAdminNuevoEmpleado({super.key});

  @override
  State<PantallaAdminNuevoEmpleado> createState() =>
      _PantallaAdminNuevoEmpleadoState();
}

class _PantallaAdminNuevoEmpleadoState
    extends State<PantallaAdminNuevoEmpleado> {
  final _ctrlNombre    = TextEditingController();
  final _ctrlApellidos = TextEditingController();
  final _ctrlEmail     = TextEditingController();
  final _ctrlTelefono  = TextEditingController();

  late final List<bool> _diasActivos;
  final Set<String> _skillsSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    _diasActivos = List<bool>.from(_activoInicial);
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlApellidos.dispose();
    _ctrlEmail.dispose();
    _ctrlTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CabeceraPantalla(
        titulo: 'Nuevo empleado',
        mostrarAtras: true,
      ),
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: POST /empleados
            },
            child: const Text('Crear empleado'),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 32),
        children: [
          // ── Placeholder foto ───────────────────────────────────────────────
          Center(
            child: _PlaceholderFoto(colorScheme: colorScheme),
          ),
          const SizedBox(height: 28),

          // ── Formulario ─────────────────────────────────────────────────────
          _CampoTexto(controlador: _ctrlNombre,    etiqueta: 'Nombre *'),
          const SizedBox(height: 12),
          _CampoTexto(controlador: _ctrlApellidos, etiqueta: 'Apellidos *'),
          const SizedBox(height: 12),
          _CampoTexto(
            controlador: _ctrlEmail,
            etiqueta: 'Email',
            teclado: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _CampoTexto(
            controlador: _ctrlTelefono,
            etiqueta: 'Teléfono',
            teclado: TextInputType.phone,
          ),
          const SizedBox(height: 28),

          // ── Horario semanal ────────────────────────────────────────────────
          Text(
            'HORARIO SEMANAL',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: espaciado.radioCard,
            ),
            child: Column(
              children: [
                for (int i = 0; i < _diasSemana.length; i++) ...[
                  FilaDiaHorario(
                    dia: _diasSemana[i],
                    activo: _diasActivos[i],
                    horario: _horarioTexto[i],
                    onChanged: (v) => setState(() => _diasActivos[i] = v),
                  ),
                  if (i < _diasSemana.length - 1)
                    Divider(height: 1, color: colorScheme.outlineVariant),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Skills ─────────────────────────────────────────────────────────
          Text(
            'SKILLS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in _skillsDisponibles)
                ChipSkill(
                  etiqueta: skill,
                  seleccionado: _skillsSeleccionadas.contains(skill),
                  onTap: () => setState(() {
                    if (_skillsSeleccionadas.contains(skill)) {
                      _skillsSeleccionadas.remove(skill);
                    } else {
                      _skillsSeleccionadas.add(skill);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets privados ───────────────────────────────────────────────────────

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // TODO: image_picker cuando se implemente
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
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.controlador,
    required this.etiqueta,
    this.teclado = TextInputType.text,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final TextInputType teclado;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    return TextField(
      controller: controlador,
      keyboardType: teclado,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: espaciado.radioInput),
      ),
    );
  }
}