import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';

// TODO: conectar ViewModel — GET /empleados (lista de profesionales)
class _Empleado {
  const _Empleado({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.skills,
  });

  final String id;
  final String nombre;
  final String rol;
  final List<String> skills;

  String get iniciales {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, 2).toUpperCase();
  }
}

/// Datos de ejemplo — 3 empleados hardcodeados.
/// TODO: sustituir por datos reales de la API.
const List<_Empleado> _empleadosEjemplo = [
  _Empleado(
    id: 'e1',
    nombre: 'Carlos Martínez',
    rol: 'Especialista Detailing',
    skills: ['Encerado', 'Pulido'],
  ),
  _Empleado(
    id: 'e2',
    nombre: 'Laura Sánchez',
    rol: 'Técnica de Limpieza',
    skills: ['Interior', 'Ozono'],
  ),
  _Empleado(
    id: 'e3',
    nombre: 'Marcos Ruiz',
    rol: 'Lavador Premium',
    skills: ['Lavado', 'Encerado'],
  ),
];

/// Paso 2 del wizard de reserva: selección de profesional.
///
/// Selección null = asignación automática, String id = empleado concreto.
/// Ruta: /nueva-reserva/empleado
class PantallaWizardEmpleado extends StatefulWidget {
  const PantallaWizardEmpleado({super.key});

  @override
  State<PantallaWizardEmpleado> createState() =>
      _PantallaWizardEmpleadoState();
}

class _PantallaWizardEmpleadoState extends State<PantallaWizardEmpleado> {
  // null = asignación automática (valor por defecto)
  String? _empleadoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final automatico  = _empleadoSeleccionado == null;

    return Scaffold(
      appBar: CabeceraWizard(
        pasoActual: 1,
        totalPasos: 5,
        titulo: 'Elige tu profesional',
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.padX,
          vertical: 16,
        ),
        children: [
          // ── Banner asignación automática ────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _empleadoSeleccionado = null),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                border: Border.all(color: colorScheme.primary),
                borderRadius: espaciado.radioCard,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: espaciado.radioBoton,
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asignación automática',
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Te asignamos al mejor profesional disponible',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _RadioVisual(seleccionado: automatico),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Separador "o elige tú" ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Divider(color: colorScheme.outline.withOpacity(0.3)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o elige tú',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: colorScheme.outline.withOpacity(0.3)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Lista de empleados ───────────────────────────────────────────
          ..._empleadosEjemplo.map((empleado) {
            final seleccionado = _empleadoSeleccionado == empleado.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: InkWell(
                  onTap: () =>
                      setState(() => _empleadoSeleccionado = empleado.id),
                  borderRadius: espaciado.radioCard,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            empleado.iniciales,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                empleado.nombre,
                                style: textTheme.displaySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(empleado.rol, style: textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: empleado.skills
                                    .map((s) => EtiquetaWizard(etiqueta: s))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        _RadioVisual(seleccionado: seleccionado),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => GestorNavegacion.irAWizardFecha(context),
            child: const Text('Siguiente'),
          ),
        ),
      ),
    );
  }
}

// ── Widget auxiliar radio visual ─────────────────────────────────────────────

class _RadioVisual extends StatelessWidget {
  const _RadioVisual({required this.seleccionado});

  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: seleccionado ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        color: seleccionado ? colorScheme.primary : Colors.transparent,
      ),
      child: seleccionado
          ? Icon(Icons.circle, size: 8, color: colorScheme.onPrimary)
          : null,
    );
  }
}