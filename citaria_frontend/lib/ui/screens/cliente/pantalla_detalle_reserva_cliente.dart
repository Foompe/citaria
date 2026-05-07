import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

// TODO: conectar ViewModel — GET /reservas/:id
class _DatosReserva {
  const _DatosReserva({
    required this.servicio,
    required this.profesionalNombre,
    required this.profesionalRol,
    required this.profesionalIniciales,
    required this.fecha,
    required this.hora,
    required this.duracion,
    required this.precioTotal,
    this.notas,
  });

  final String servicio;
  final String profesionalNombre;
  final String profesionalRol;
  final String profesionalIniciales;
  final String fecha;
  final String hora;
  final String duracion;
  final String precioTotal;
  final String? notas;
}

/// Datos de ejemplo hardcodeados hasta disponer de la API.
/// TODO: sustituir por GET /reservas/:id
const _reservaEjemplo = _DatosReserva(
  servicio: 'Lavado Premium + Encerado',
  profesionalNombre: 'Carlos Martínez',
  profesionalRol: 'Especialista Detailing',
  profesionalIniciales: 'CM',
  fecha: 'Mar, 21 abr 2026',
  hora: '10:30',
  duracion: '90 min',
  precioTotal: '75 €',
  notas: 'Por favor, atención especial en los bajos del vehículo.',
);

/// Pantalla de detalle de una reserva del cliente.
///
/// Misma estructura visual que [PantallaDetalleServicio]:
/// hero (32 %) + sheet deslizable.
///
/// Ruta: /reserva/:id  —  arguments: {'id': String}
class PantallaDetalleReservaCliente extends StatelessWidget {
  const PantallaDetalleReservaCliente({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // TODO: conectar ViewModel — usar id para GET /reservas/:id
    // ignore: unused_local_variable
    final id = args['id'] as String;

    final espaciado    = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme  = Theme.of(context).colorScheme;
    final textTheme    = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    // TODO: datos reales de la API
    const reserva = _reservaEjemplo;

    return Scaffold(
      body: Stack(
        children: [
          // ── Hero (32 % de la pantalla) ───────────────────────────────────
          Container(
            height: screenHeight * 0.32,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
            // TODO: Image.network con imagen del servicio cuando haya assets
          ),

          // ── Botón atrás flotante (glass) ─────────────────────────────────
          // Excepción de color literal: blanco con opacidad sobre imagen/gradiente.
          Positioned(
            top: espaciado.safeTop,
            left: espaciado.padX,
            child: Semantics(
              label: 'Volver',
              child: Tooltip(
                message: 'Volver',
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: espaciado.radioPill,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.30),
                      borderRadius: espaciado.radioPill,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // ── Sheet deslizable ─────────────────────────────────────────────
          Positioned(
            top: screenHeight * 0.32 - 22,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(espaciado.radioCard.topLeft.x * 2),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  16,
                  espaciado.padX,
                  espaciado.safeBottom + 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grabber
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

                    // TODO: mostrar estado real de la reserva
                    const ChipEstado(estado: EstadoReserva.pendiente),
                    const SizedBox(height: 12),

                    Text(reserva.servicio, style: textTheme.displayMedium),
                    const SizedBox(height: 20),

                    // ── Card profesional ─────────────────────────────────
                    _CardSeccion(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              reserva.profesionalIniciales,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reserva.profesionalNombre,
                                style: textTheme.displaySmall,
                              ),
                              Text(
                                reserva.profesionalRol,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Card fecha y hora ────────────────────────────────
                    _CardSeccion(
                      child: Column(
                        children: [
                          _FilaInfo(
                            icono: Icons.calendar_today,
                            label: 'Fecha',
                            valor: reserva.fecha,
                          ),
                          Divider(
                            color: colorScheme.outline.withOpacity(0.2),
                            height: 20,
                          ),
                          _FilaInfo(
                            icono: Icons.access_time,
                            label: 'Hora / Duración',
                            valor: '${reserva.hora} · ${reserva.duracion}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Card precio total ────────────────────────────────
                    _CardSeccion(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: textTheme.bodyLarge),
                          Text(
                            reserva.precioTotal,
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Card notas (condicional) ──────────────────────────
                    if (reserva.notas != null) ...[
                      const SizedBox(height: 10),
                      _CardSeccion(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notes,
                              size: 18,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reserva.notas!,
                                style: textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── CTA fija ─────────────────────────────────────────────────────────
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            // TODO: llamar API cancelar reserva — DELETE /reservas/:id
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
            child: const Text('Cancelar reserva'),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares privados ───────────────────────────────────────────────

class _CardSeccion extends StatelessWidget {
  const _CardSeccion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: espaciado.radioCard,
      ),
      child: child,
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.label,
    required this.valor,
  });

  final IconData icono;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.outline),
        const SizedBox(width: 10),
        Text(label, style: textTheme.bodySmall),
        const Spacer(),
        Text(valor, style: textTheme.bodyMedium),
      ],
    );
  }
}