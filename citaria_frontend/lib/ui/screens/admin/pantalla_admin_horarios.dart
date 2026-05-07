import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/fila_dia_horario.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Constantes de dominio ─────────────────────────────────────────────────────

const List<String> _diasSemana = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

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

class _CierrePuntual {
  _CierrePuntual({required this.fecha, required this.motivo});
  final String fecha;
  final String motivo;
}

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P33 — Gestión de horarios del negocio.
class PantallaAdminHorarios extends StatefulWidget {
  const PantallaAdminHorarios({super.key});

  @override
  State<PantallaAdminHorarios> createState() => _PantallaAdminHorariosState();
}

class _PantallaAdminHorariosState extends State<PantallaAdminHorarios> {
  late final List<bool> _diasActivos;

  // TODO: cierres reales de API
  final List<_CierrePuntual> _cierres = [
    _CierrePuntual(fecha: '24 dic 2025', motivo: 'Nochebuena'),
    _CierrePuntual(fecha: '31 dic 2025', motivo: 'Nochevieja'),
  ];

  @override
  void initState() {
    super.initState();
    _diasActivos = List<bool>.from(_activoInicial);
  }

  void _eliminarCierre(int index) {
    setState(() => _cierres.removeAt(index));
  }

  void _anadirCierre() {
    // TODO: mostrar DatePicker + campo motivo
    // Por ahora añade cierre hardcodeado
    setState(() {
      _cierres.add(
        _CierrePuntual(fecha: '15 ago 2025', motivo: 'Vacaciones'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    // TODO: calcular reservas reales afectadas — hardcodeado "3 reservas"
    final hayReservasAfectadas = _cierres.isNotEmpty;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.mas,
      ),
      appBar: const CabeceraPantalla(
        titulo: 'Horarios',
        mostrarAtras: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _anadirCierre,
        icon: const Icon(Icons.add),
        label: const Text('Añadir cierre'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX, 16, espaciado.padX, 120,
        ),
        children: [
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
            shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
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

          // ── Cierres puntuales ──────────────────────────────────────────────
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
            child: _cierres.isEmpty
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
                      for (int i = 0; i < _cierres.length; i++) ...[
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                          title: Text(
                            _cierres[i].fecha,
                            style: textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            _cierres[i].motivo,
                            style: textTheme.bodySmall,
                          ),
                          trailing: Tooltip(
                            message: 'Eliminar cierre',
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _eliminarCierre(i),
                            ),
                          ),
                        ),
                        if (i < _cierres.length - 1)
                          Divider(
                            height: 1,
                            color: colorScheme.outlineVariant,
                          ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // ── Banner warning ─────────────────────────────────────────────────
          if (hayReservasAfectadas)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: espaciado.radioCard,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      // TODO: calcular reservas reales afectadas
                      '3 reservas afectadas por los cierres programados',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}