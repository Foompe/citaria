import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
// TODO: GET /empleados

class _Empleado {
  const _Empleado({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.activo,
    required this.skills,
  });

  final String id;
  final String nombre;
  final String rol;
  final bool activo;
  final List<String> skills;
}

const List<_Empleado> _empleados = [
  _Empleado(
    id: 'e1',
    nombre: 'Carlos Martínez',
    rol: 'Detailer Senior',
    activo: true,
    skills: ['Exterior', 'Pulido', 'Cera', 'Premium'],
  ),
  _Empleado(
    id: 'e2',
    nombre: 'Ana Rodríguez',
    rol: 'Detailer',
    activo: true,
    skills: ['Interior', 'Tapicería', 'Aspirado'],
  ),
  _Empleado(
    id: 'e3',
    nombre: 'David López',
    rol: 'Detailer Junior',
    activo: true,
    skills: ['Exterior', 'Aspirado'],
  ),
  _Empleado(
    id: 'e4',
    nombre: 'Marta Sánchez',
    rol: 'Recepcionista',
    activo: false,
    skills: ['Detallado'],
  ),
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P28 — Listado de empleados del área admin protegida por PIN.
class PantallaAdminEmpleados extends StatelessWidget {
  const PantallaAdminEmpleados({super.key});

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.mas,
      ),
      appBar: CabeceraPantalla(
        titulo: 'Empleados',
        mostrarAtras: false,
        accionDerecha: Tooltip(
          message: 'Nuevo empleado',
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => GestorNavegacion.irAAdminNuevoEmpleado(context),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.padX,
          vertical: 12,
        ),
        itemCount: _empleados.length,
        itemBuilder: (context, index) {
          final empleado = _empleados[index];
          return _TarjetaEmpleado(
            empleado: empleado,
            iniciales: _iniciales(empleado.nombre),
            colorScheme: colorScheme,
            textTheme: textTheme,
            espaciado: espaciado,
          );
        },
      ),
    );
  }
}

// ── Tarjeta de empleado ───────────────────────────────────────────────────────

class _TarjetaEmpleado extends StatelessWidget {
  const _TarjetaEmpleado({
    required this.empleado,
    required this.iniciales,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final _Empleado empleado;
  final String iniciales;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    const int maxSkillsVisibles = 2;
    final skillsVisibles = empleado.skills.take(maxSkillsVisibles).toList();
    final skillsExtra = empleado.skills.length - maxSkillsVisibles;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: InkWell(
        borderRadius: espaciado.radioCard,
        onTap: () =>
            GestorNavegacion.irAAdminDetalleEmpleado(context, empleado.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  iniciales,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + indicador activo
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            empleado.nombre,
                            style: textTheme.displaySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: empleado.activo
                                ? Colors.green
                                : colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Rol
                    Text(
                      empleado.rol,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Skills
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final skill in skillsVisibles)
                          EtiquetaWizard(etiqueta: skill),
                        if (skillsExtra > 0)
                          Text(
                            '+$skillsExtra más',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron
              Semantics(
                label: 'Ver detalle de ${empleado.nombre}',
                child: Icon(
                  Icons.chevron_right,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}