import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P35 — Ajustes del área admin protegida por PIN.
class PantallaAdminAjustes extends StatelessWidget {
  const PantallaAdminAjustes({super.key});

  void _mostrarDialogoCambiarPin(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final ctrlPinActual   = TextEditingController();
    final ctrlPinNuevo    = TextEditingController();
    final ctrlPinConfirma = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
        title: const Text('Cambiar PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrlPinActual,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PIN actual',
                border: OutlineInputBorder(
                  borderRadius: espaciado.radioInput,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlPinNuevo,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PIN nuevo',
                border: OutlineInputBorder(
                  borderRadius: espaciado.radioInput,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlPinConfirma,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Confirmar PIN nuevo',
                border: OutlineInputBorder(
                  borderRadius: espaciado.radioInput,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: validar y guardar nuevo PIN en shared_preferences
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ).then((_) {
      ctrlPinActual.dispose();
      ctrlPinNuevo.dispose();
      ctrlPinConfirma.dispose();
    });
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
      appBar: const CabeceraPantalla(
        titulo: 'Ajustes',
        mostrarAtras: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          espaciado.padX, 16, espaciado.padX, 32,
        ),
        children: [
          // ── Sección Empresa ────────────────────────────────────────────────
          Text(
            'EMPRESA',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: datos reales de shared_preferences / API
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: espaciado.radioCard,
            ),
            child: Column(
              children: [
                _FilaInfo(
                  icono: Icons.business_outlined,
                  etiqueta: 'Nombre',
                  valor: 'DetailCarWash',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _FilaInfo(
                  icono: Icons.location_on_outlined,
                  etiqueta: 'Dirección',
                  valor: 'Calle Mayor 1, Madrid',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _FilaInfo(
                  icono: Icons.phone_outlined,
                  etiqueta: 'Teléfono',
                  valor: '+34 91 000 00 00',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                _FilaInfo(
                  icono: Icons.email_outlined,
                  etiqueta: 'Email',
                  valor: 'info@detailcarwash.es',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  espaciado: espaciado,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Sección Seguridad ──────────────────────────────────────────────
          Text(
            'SEGURIDAD',
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
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarDialogoCambiarPin(context),
            ),
          ),
          const SizedBox(height: 28),

          // ── Sección Cuenta ─────────────────────────────────────────────────
          Text(
            'CUENTA',
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
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: colorScheme.error,
              ),
              title: Text(
                'Cerrar sesión',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              onTap: () => GestorNavegacion.irACerrarSesion(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _FilaInfo ─────────────────────────────────────────────────────────────────

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: colorScheme.outline),
      title: Text(
        etiqueta,
        style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
      ),
      subtitle: Text(valor, style: textTheme.bodyLarge),
    );
  }
}