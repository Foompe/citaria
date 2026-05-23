import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Menú lateral (Drawer) del área de administración.
///
/// Se usa como [Scaffold.drawer] en todas las pantallas admin.
/// Las secciones protegidas por PIN tienen un icono candado como
/// trailing — la protección real ocurre en [GuardianPin].
class MenuLateralAdmin extends StatelessWidget {
  const MenuLateralAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final autenticacion = context.watch<ViewModelAutenticacion>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── CABECERA ──────────────────────────────────────────────────
            _Cabecera(
              empresa: autenticacion.empresaActiva,
              email: autenticacion.usuarioActual?.email,
              colorScheme: colorScheme,
              textTheme: textTheme,
              espaciado: espaciado,
            ),

            // ── CUERPO scrollable ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // SECCIÓN OPERACIONES
                  _SeccionLabel(
                    etiqueta: 'OPERACIONES',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  _ItemMenu(
                    icono: Icons.home_outlined,
                    titulo: 'Inicio',
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminInicio(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.calendar_today_outlined,
                    titulo: 'Reservas',
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminReservas(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.people_outline,
                    titulo: 'Clientes',
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminClientes(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.grid_view_outlined,
                    titulo: 'Calendario',
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminCalendario(ctx);
                    },
                  ),

                  const Divider(),

                  // SECCIÓN PROTEGIDAS
                  _SeccionLabel(
                    etiqueta: 'PROTEGIDAS',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  _ItemMenu(
                    icono: Icons.badge_outlined,
                    titulo: 'Empleados',
                    protegida: true,
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminEmpleados(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.grid_view_outlined,
                    titulo: 'Catálogo',
                    protegida: true,
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminCatalogo(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.schedule_outlined,
                    titulo: 'Horarios',
                    protegida: true,
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminHorarios(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.bar_chart_outlined,
                    titulo: 'Estadísticas',
                    protegida: true,
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminEstadisticas(ctx);
                    },
                  ),
                  _ItemMenu(
                    icono: Icons.settings_outlined,
                    titulo: 'Ajustes',
                    protegida: true,
                    onTap: (ctx) {
                      Navigator.pop(ctx);
                      GestorNavegacion.irAAdminAjustes(ctx);
                    },
                  ),
                ],
              ),
            ),

            // ── PIE ───────────────────────────────────────────────────────
            _Pie(colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

// ── Subwidgets privados ────────────────────────────────────────────────────────

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.empresa,
    required this.email,
    required this.colorScheme,
    required this.textTheme,
    required this.espaciado,
  });

  final DtoEmpresaActiva? empresa;
  final String? email;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.primary,
      padding: EdgeInsets.fromLTRB(espaciado.padX, 12, espaciado.padX, 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarFallbackCitaria(
              texto: empresa?.nombre ?? 'Citaria',
              imagenUrl: empresa?.logoUrl,
              tamano: 72,
              radio: 18,
            ),
            const SizedBox(height: 12),
            Text(
              empresa?.nombre ?? 'Citaria',
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (email != null && email!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                email!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.82),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeccionLabel extends StatelessWidget {
  const _SeccionLabel({
    required this.etiqueta,
    required this.textTheme,
    required this.colorScheme,
  });

  final String etiqueta;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        etiqueta,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.protegida = false,
  });

  final IconData icono;
  final String titulo;
  final bool protegida;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      trailing: protegida ? const Icon(Icons.lock_outline, size: 14) : null,
      onTap: () => onTap(context),
    );
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          onTap: () {
            Navigator.pop(context);
            GestorNavegacion.irACerrarSesion(context);
          },
        ),
      ],
    );
  }
}
