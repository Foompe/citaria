import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_perfil_cliente.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelPerfilCliente>().cargarPerfilDesdeSesion();
    });
  }

  Future<void> _cerrarSesion() async {
    await context.read<ViewModelPerfilCliente>().cerrarSesion();
    if (!mounted) return;
    GestorNavegacion.irACerrarSesion(context);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final perfil = context.watch<ViewModelPerfilCliente>().datos;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.perfil,
      ),
      body: SafeArea(
        child: perfil == null
            ? Center(
                child: Text(
                  context.watch<ViewModelPerfilCliente>().cargando
                      ? 'Cargando perfil...'
                      : 'No se ha podido cargar el perfil.',
                  style: textTheme.bodyLarge,
                ),
              )
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      label: 'Ajustes',
                      child: const IconButton(
                        tooltip: 'Ajustes',
                        icon: Icon(Icons.settings_outlined),
                        onPressed: null,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            perfil.iniciales,
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          perfil.nombreCompleto,
                          style: textTheme.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
                          icono: Icons.person_outline,
                          label: 'Nombre',
                          valor: perfil.nombre,
                        ),
                        const _Divisor(),
                        _FilaDato(
                          icono: Icons.badge_outlined,
                          label: 'Apellidos',
                          valor: perfil.apellidos,
                        ),
                        const _Divisor(),
                        _FilaDato(
                          icono: Icons.email_outlined,
                          label: 'Email',
                          valor: perfil.email,
                        ),
                        const _Divisor(),
                        _FilaDato(
                          icono: Icons.phone_outlined,
                          label: 'Teléfono',
                          valor: perfil.telefono,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: InkWell(
                      onTap: () => GestorNavegacion.irACambiarEmpresa(context),
                      borderRadius: espaciado.radioCard,
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
                  Center(
                    child: TextButton(
                      onPressed: _cerrarSesion,
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

class _FilaDato extends StatelessWidget {
  const _FilaDato({
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
    final textTheme = Theme.of(context).textTheme;

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
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 48,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
    );
  }
}
