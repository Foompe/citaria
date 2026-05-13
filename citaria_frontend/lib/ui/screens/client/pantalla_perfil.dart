import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';

/// Pantalla de perfil del cliente (P10).
///
/// Muestra datos del usuario, opciones de cuenta y cierre de sesión.
///
/// HARDCODING TEMPORAL:
///   - Nombre, email y campos de datos: fijos → TODO: leer de ViewModelAutenticacion
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final espaciado  = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme  = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.perfil,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
          children: [
            // ── Cabecera sin título ────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                label: 'Ajustes',
                child: IconButton(
                  tooltip: 'Ajustes',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: null, // TODO: pantalla ajustes (Capa 3)
                ),
              ),
            ),

            // ── Avatar y datos de cabecera ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      // TODO: iniciales reales del ViewModelAutenticacion
                      'CV',
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    // TODO: nombre real del ViewModelAutenticacion
                    'Carlos Vega',
                    style: textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // TODO: email real del ViewModelAutenticacion
                    'carlos.vega@email.com',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Sección "Mis datos" ────────────────────────────────────────
            Text(
              'Mis datos',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _FilaDato(
                    icono:  Icons.person_outline,
                    label:  'Nombre',
                    // TODO: valor real del ViewModelAutenticacion
                    valor:  'Carlos',
                  ),
                  _Divisor(),
                  _FilaDato(
                    icono:  Icons.badge_outlined,
                    label:  'Apellidos',
                    // TODO: valor real del ViewModelAutenticacion
                    valor:  'Vega',
                  ),
                  _Divisor(),
                  _FilaDato(
                    icono:  Icons.email_outlined,
                    label:  'Email',
                    // TODO: valor real del ViewModelAutenticacion
                    valor:  'carlos.vega@email.com',
                  ),
                  _Divisor(),
                  _FilaDato(
                    icono:  Icons.phone_outlined,
                    label:  'Teléfono',
                    // TODO: valor real del ViewModelAutenticacion
                    valor:  '+34 600 000 000',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Cambiar empresa ────────────────────────────────────────────
            Card(
              child: InkWell(
                onTap: () => GestorNavegacion.irACambiarEmpresa(context),
                borderRadius:
                    Theme.of(context).extension<EspaciadoCitaria>()!.radioCard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cambiar empresa',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Cerrar sesión ──────────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: () => GestorNavegacion.irACerrarSesion(context),
                child: Text(
                  'Cerrar sesión',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),

            SizedBox(height: espaciado.safeBottom),
          ],
        ),
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.icono,
    required this.label,
    required this.valor,
  });

  final IconData icono;
  final String   label;
  final String   valor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme  = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: colorScheme.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(valor, style: textTheme.bodyLarge),
              ],
            ),
          ),
          Semantics(
            label: 'Editar $label',
            child: IconButton(
              tooltip: 'Editar $label',
              icon: Icon(
                Icons.edit_outlined,
                color: colorScheme.outline,
                size: 18,
              ),
              onPressed: null, // TODO: edición inline en Capa 3
            ),
          ),
        ],
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
    );
  }
}