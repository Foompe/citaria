import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_wizard.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';

// TODO: conectar ViewModel — GET /servicios (lista del catálogo)
class _Servicio {
  const _Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMin,
    required this.precio,
  });

  final String id;
  final String nombre;
  final String categoria;
  final int duracionMin;
  final double precio;

  String get duracionTexto => '$duracionMin min';
  String get precioTexto => '${precio.toStringAsFixed(0)} €';
}

/// Datos de ejemplo — 4 servicios hardcodeados.
/// TODO: sustituir por datos reales de la API.
const List<_Servicio> _serviciosEjemplo = [
  _Servicio(
    id: 's1',
    nombre: 'Lavado Exterior',
    categoria: 'Exterior',
    duracionMin: 30,
    precio: 20,
  ),
  _Servicio(
    id: 's2',
    nombre: 'Limpieza Interior',
    categoria: 'Interior',
    duracionMin: 45,
    precio: 30,
  ),
  _Servicio(
    id: 's3',
    nombre: 'Lavado Premium + Encerado',
    categoria: 'Exterior',
    duracionMin: 90,
    precio: 75,
  ),
  _Servicio(
    id: 's4',
    nombre: 'Detailing Completo',
    categoria: 'Detailing',
    duracionMin: 180,
    precio: 150,
  ),
];

/// Paso 1 del wizard de reserva: selección de servicios.
///
/// Ruta: /nueva-reserva/servicios
/// arguments: {'servicioPreseleccionado': String?}
class PantallaWizardServicios extends StatefulWidget {
  const PantallaWizardServicios({super.key});

  @override
  State<PantallaWizardServicios> createState() =>
      _PantallaWizardServiciosState();
}

class _PantallaWizardServiciosState extends State<PantallaWizardServicios> {
  final Set<String> _seleccionados = {};
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final preseleccionado = args['servicioPreseleccionado'] as String?;
        if (preseleccionado != null) {
          _seleccionados.add(preseleccionado);
        }
      }
    }
  }

  int get _totalMinutos => _serviciosEjemplo
      .where((s) => _seleccionados.contains(s.id))
      .fold(0, (sum, s) => sum + s.duracionMin);

  double get _totalPrecio => _serviciosEjemplo
      .where((s) => _seleccionados.contains(s.id))
      .fold(0.0, (sum, s) => sum + s.precio);

  void _toggleServicio(String id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final haySeleccion = _seleccionados.isNotEmpty;

    return Scaffold(
      appBar: CabeceraWizard(
        pasoActual: 0,
        totalPasos: 5,
        titulo: 'Elige tus servicios',
      ),

      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: espaciado.padX, vertical: 12),
        itemCount: _serviciosEjemplo.length,
        separatorBuilder: (_, __) =>
            Divider(color: colorScheme.outline.withOpacity(0.15)),
        itemBuilder: (context, index) {
          final servicio = _serviciosEjemplo[index];
          final seleccionado = _seleccionados.contains(servicio.id);

          return InkWell(
            onTap: () => _toggleServicio(servicio.id),
            borderRadius: espaciado.radioCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Checkbox visual
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: espaciado.radioBoton,
                      border: Border.all(
                        color: seleccionado
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    child: seleccionado
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(servicio.nombre, style: textTheme.displaySmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              servicio.duracionTexto,
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              servicio.precioTexto,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  EtiquetaWizard(etiqueta: servicio.categoria),
                ],
              ),
            ),
          );
        },
      ),

      // ── CTA fija ─────────────────────────────────────────────────────────
      // El Row tiene: columna resumen (Expanded) + SizedBox fijo + botón
      // acotado. El botón NO va en Expanded para que el resumen tenga
      // prioridad de espacio.
      bottomNavigationBar: BarraCtaFija(
        child: Row(
          children: [
            // ── Resumen (ocupa todo el espacio disponible) ───────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_seleccionados.length} '
                    'servicio${_seleccionados.length == 1 ? '' : 's'} '
                    '· $_totalMinutos min',
                    style: textTheme.bodySmall,
                  ),
                  if (haySeleccion)
                    Text(
                      '${_totalPrecio.toStringAsFixed(0)} €',
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Botón con ancho controlado ───────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 48,
                maxWidth: 160, // 👈 CLAVE: evita infinito
              ),
              child: ElevatedButton(
                onPressed: haySeleccion
                    ? () => GestorNavegacion.irAWizardEmpleado(context)
                    : null,
                child: const Text('Siguiente →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
