import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';

// TODO: conectar ViewModel — GET /servicios/:id
class _DatosServicio {
  const _DatosServicio({
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.duracion,
    required this.precio,
    required this.skills,
  });

  final String nombre;
  final String categoria;
  final String descripcion;
  final String duracion;
  final String precio;
  final List<String> skills;
}

const _servicioEjemplo = _DatosServicio(
  nombre: 'Lavado Premium + Encerado',
  categoria: 'Exterior',
  descripcion:
      'Lavado a mano con productos de alta gama, descontaminación de la '
      'carrocería y encerado de protección de larga duración. Resultado '
      'profesional garantizado.',
  duracion: '90 min',
  precio: '75 €',
  skills: ['Lavado', 'Encerado', 'Detailing'],
);

/// Pantalla de detalle de un servicio.
///
/// Estructura: [Stack] con hero (40 % de altura) + sheet deslizable.
/// El parámetro [modoAdmin] controla la visibilidad de las skills requeridas.
///
/// Ruta: /servicio/:id  —  arguments: {'id': String}
class PantallaDetalleServicio extends StatelessWidget {
  const PantallaDetalleServicio({super.key, this.modoAdmin = false});
  final bool modoAdmin;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final id = args['id'] as String;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final servicio = _servicioEjemplo;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Cabecera flexible (Reemplaza al Hero + Botón atrás)
          SliverAppBar(
            expandedHeight: screenHeight * 0.40,
            pinned: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: BackButton(color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
          ),

          // 2. Cuerpo de la pantalla (La "Sheet" blanca)
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24), // Crea el efecto de solapamiento
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(espaciado.radioCard.topLeft.x * 2),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withOpacity(0.3),
                          borderRadius: espaciado.radioPill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EtiquetaWizard(etiqueta: servicio.categoria),
                    const SizedBox(height: 10),
                    Text(servicio.nombre, style: textTheme.displayLarge),
                    const SizedBox(height: 10),
                    Text(servicio.descripcion, style: textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Divider(color: colorScheme.outline.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    _FilaDetalle(
                      icono: Icons.access_time,
                      label: 'Duración',
                      valor: servicio.duracion,
                    ),
                    const SizedBox(height: 12),
                    _FilaDetalle(
                      icono: Icons.euro,
                      label: 'Precio',
                      valor: servicio.precio,
                      estiloValor: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                    ),
                    if (modoAdmin) ...[
                      const SizedBox(height: 20),
                      Text('Skills requeridas', style: textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: servicio.skills.map((s) => EtiquetaWizard(etiqueta: s)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => GestorNavegacion.irAWizardServicios(context, servicioPreseleccionado: id),
            child: const Text('Reservar este servicio'),
          ),
        ),
      ),
    );
  }
}

// ── Widget auxiliar privado ───────────────────────────────────────────────────

class _FilaDetalle extends StatelessWidget {
  const _FilaDetalle({
    required this.icono,
    required this.label,
    required this.valor,
    this.estiloValor,
  });

  final IconData icono;
  final String label;
  final String valor;
  final TextStyle? estiloValor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.outline),
        const SizedBox(width: 10),
        Text(label, style: textTheme.bodyLarge),
        const Spacer(),
        Text(valor, style: estiloValor ?? textTheme.bodyMedium),
      ],
    );
  }
}