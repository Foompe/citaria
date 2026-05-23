import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_usuarios.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_ajustes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PantallaAdminAjustes extends StatefulWidget {
  const PantallaAdminAjustes({super.key});

  @override
  State<PantallaAdminAjustes> createState() => _PantallaAdminAjustesState();
}

class _PantallaAdminAjustesState extends State<PantallaAdminAjustes> {
  late final ViewModelAdminAjustes _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminAjustes(
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      repoUsuarios: context.read<RepoUsuarios>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarAjustes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _mostrarDialogoCambiarPin(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    final ctrlPinActual = TextEditingController();
    final ctrlPinNuevo = TextEditingController();
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
                border: OutlineInputBorder(borderRadius: espaciado.radioInput),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlPinNuevo,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PIN nuevo',
                border: OutlineInputBorder(borderRadius: espaciado.radioInput),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlPinConfirma,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Confirmar PIN nuevo',
                border: OutlineInputBorder(borderRadius: espaciado.radioInput),
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
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cambio de PIN pendiente de conectar.'),
                ),
              );
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
    return ChangeNotifierProvider<ViewModelAdminAjustes>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminAjustes>(
        builder: (context, vmAjustes, _) => Scaffold(
          drawer: const MenuLateralAdmin(),
          bottomNavigationBar: const BarraNavegacionAdmin(
            seccionActiva: SeccionAdmin.mas,
          ),
          appBar: const CabeceraPantalla(
            titulo: 'Ajustes',
            mostrarAtras: false,
          ),
          body: _CuerpoAjustes(
            vmAjustes: vmAjustes,
            onCambiarPin: () => _mostrarDialogoCambiarPin(context),
          ),
        ),
      ),
    );
  }
}

class _CuerpoAjustes extends StatelessWidget {
  const _CuerpoAjustes({required this.vmAjustes, required this.onCambiarPin});

  final ViewModelAdminAjustes vmAjustes;
  final VoidCallback onCambiarPin;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vmAjustes.cargando &&
        vmAjustes.empresa == null &&
        vmAjustes.cuenta == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmAjustes.error;
    if (error != null &&
        vmAjustes.empresa == null &&
        vmAjustes.cuenta == null) {
      return _EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmAjustes.refrescar,
      );
    }

    return RefreshIndicator(
      onRefresh: vmAjustes.refrescar,
      child: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 32),
        children: [
          _Seccion(
            titulo: 'EMPRESA',
            children: _filasEmpresa(vmAjustes.empresa),
          ),
          const SizedBox(height: 28),
          _Seccion(
            titulo: 'BRANDING',
            children: _filasVisual(vmAjustes.visual),
          ),
          const SizedBox(height: 28),
          _Seccion(titulo: 'CUENTA', children: _filasCuenta(vmAjustes.cuenta)),
          const SizedBox(height: 28),
          Text(
            'SEGURIDAD',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onCambiarPin,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'SESIÓN',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Cerrar sesión',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              ),
              onTap: () => GestorNavegacion.irACerrarSesion(context),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            _AvisoError(mensaje: error),
          ],
        ],
      ),
    );
  }

  List<Widget> _filasEmpresa(DtoAjustesEmpresaAdmin? empresa) {
    if (empresa == null) {
      return const <Widget>[
        _FilaInfo(icono: Icons.info_outline, etiqueta: 'Empresa', valor: '-'),
      ];
    }
    return <Widget>[
      _FilaInfo(
        icono: Icons.business_outlined,
        etiqueta: 'Nombre',
        valor: empresa.nombre,
      ),
      _FilaInfo(
        icono: Icons.location_on_outlined,
        etiqueta: 'Dirección',
        valor: empresa.direccion,
      ),
      _FilaInfo(
        icono: Icons.phone_outlined,
        etiqueta: 'Teléfono',
        valor: empresa.telefono,
      ),
      _FilaInfo(
        icono: Icons.email_outlined,
        etiqueta: 'Email',
        valor: empresa.email,
      ),
      _FilaInfo(
        icono: Icons.badge_outlined,
        etiqueta: 'CIF',
        valor: empresa.cif,
      ),
      _FilaInfo(
        icono: Icons.public_outlined,
        etiqueta: 'País',
        valor: empresa.pais,
      ),
    ];
  }

  List<Widget> _filasVisual(DtoAjustesVisualAdmin? visual) {
    if (visual == null) {
      return const <Widget>[
        _FilaInfo(
          icono: Icons.palette_outlined,
          etiqueta: 'Branding',
          valor: '-',
        ),
      ];
    }
    return <Widget>[
      _FilaInfo(
        icono: Icons.image_outlined,
        etiqueta: 'Logo',
        valor: visual.logoUrl,
      ),
      _FilaInfo(
        icono: Icons.format_color_fill_outlined,
        etiqueta: 'Color primario',
        valor: visual.colorPrimario,
      ),
      _FilaInfo(
        icono: Icons.color_lens_outlined,
        etiqueta: 'Color secundario',
        valor: visual.colorSecundario,
      ),
      _FilaInfo(
        icono: Icons.text_fields_outlined,
        etiqueta: 'Tipografía',
        valor: visual.tipografia,
      ),
      _FilaInfo(
        icono: Icons.new_releases_outlined,
        etiqueta: 'Versión',
        valor: visual.version,
      ),
    ];
  }

  List<Widget> _filasCuenta(DtoAjustesCuentaAdmin? cuenta) {
    if (cuenta == null) {
      return const <Widget>[
        _FilaInfo(icono: Icons.person_outline, etiqueta: 'Cuenta', valor: '-'),
      ];
    }
    return <Widget>[
      _FilaInfo(
        icono: Icons.alternate_email_outlined,
        etiqueta: 'Email',
        valor: cuenta.email,
      ),
      _FilaInfo(
        icono: Icons.admin_panel_settings_outlined,
        etiqueta: 'Rol',
        valor: cuenta.rol,
      ),
      _FilaInfo(
        icono: Icons.verified_user_outlined,
        etiqueta: 'Estado',
        valor: cuenta.estado,
      ),
      _FilaInfo(
        icono: Icons.mark_email_read_outlined,
        etiqueta: 'Email verificado',
        valor: cuenta.emailVerificado,
      ),
    ];
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
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
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(height: 1, color: colorScheme.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

class _AvisoError extends StatelessWidget {
  const _AvisoError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: espaciado.radioCard,
      ),
      child: Text(
        mensaje,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

class _EstadoCentrado extends StatelessWidget {
  const _EstadoCentrado({
    required this.mensaje,
    required this.accionTexto,
    required this.onAccion,
  });

  final String mensaje;
  final String accionTexto;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAccion, child: Text(accionTexto)),
          ],
        ),
      ),
    );
  }
}
