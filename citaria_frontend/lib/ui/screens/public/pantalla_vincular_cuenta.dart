import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';

/// P06 — Vincular cuenta.
///
/// Se muestra cuando el email del formulario de registro ya existe
/// en el sistema. Ofrece vincular la cuenta existente o crear una nueva.
class PantallaVincularCuenta extends StatelessWidget {
  const PantallaVincularCuenta({super.key});

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CabeceraPantalla(
        titulo: '',
        mostrarAtras: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX,
          16,
          espaciado.padX,
          espaciado.safeBottom,
        ),
        child: Column(
          children: [
            // ── Bloque informativo ──────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de candado
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: espaciado.radioCard,
                    ),
                    alignment: Alignment.center,
                    child: Semantics(
                      label: 'Icono de candado',
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ya te tenemos en el sistema',
                    style: textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu email ya está registrado. '
                    '¿Quieres vincular tu cuenta?',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Botones ─────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: conectar API — vincular cuenta existente con
                    // los datos introducidos en P05. POST /auth/vincular
                    GestorNavegacion.irAHomeCliente(context);
                  },
                  child: const Text('Sí, vincular mi cuenta'),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    // TODO: conectar API — crear cuenta nueva ignorando
                    // el conflicto de email. POST /auth/registro/forzar
                    GestorNavegacion.irAHomeCliente(context);
                  },
                  child: const Text('No, crear cuenta nueva'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}