import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart';

/// Tarjeta de resumen de una reserva para las vistas del área admin.
///
/// Muestra estado, hora, nombre del cliente, servicio, empleado y precio.
/// Toda la tarjeta es táctil — delega la acción en [onTap].
class TarjetaReservaAdmin extends StatelessWidget {
  const TarjetaReservaAdmin({
    super.key,
    required this.estado,
    required this.cliente,
    required this.servicio,
    required this.empleado,
    required this.hora,
    required this.precio,
    required this.onTap,
  });

  final EstadoReserva estado;
  final String cliente;
  final String servicio;
  final String empleado;
  final String hora;
  final String precio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: espaciado.padX,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: espaciado.radioCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: chip estado + hora
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChipEstado(estado: estado),
                  Text(
                    hora,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Nombre cliente
              Text(
                cliente,
                style: textTheme.displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Fila inferior: servicio · empleado + precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$servicio · $empleado',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    precio,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}