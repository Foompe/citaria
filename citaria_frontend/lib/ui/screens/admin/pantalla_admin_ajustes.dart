import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_usuarios.dart';
import 'package:citaria_frontend/ui/widgets/dialogo_cambiar_contrasena.dart';
import 'package:citaria_frontend/ui/widgets/dialogo_cambiar_pin.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/aviso_error.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/campo_formulario.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';
import 'package:citaria_frontend/ui/utils/validadores.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_empresa_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_cuenta_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_ajustes_visual_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_ajustes.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
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

  Future<void> _mostrarDialogoCambiarContrasena(
    BuildContext context,
    ViewModelAdminAjustes vmAjustes,
  ) async {
    final bool? guardado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogoCambiarContrasena(
        onCambiar: (actual, nueva) => vmAjustes.cambiarPassword(
          passwordActual: actual,
          passwordNueva: nueva,
        ),
      ),
    );
    if (!context.mounted || guardado != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña actualizada correctamente.')),
    );
  }

  Future<void> _mostrarDialogoCambiarPin(BuildContext context) async {
    final bool? guardado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DialogoCambiarPin(),
    );
    if (!context.mounted || guardado != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN actualizado correctamente.')),
    );
  }

  Future<void> _mostrarDialogoEditarEmpresa(
    BuildContext context,
    ViewModelAdminAjustes vmAjustes,
  ) async {
    final DtoAjustesEmpresaAdmin? empresa = vmAjustes.empresa;
    if (empresa == null) {
      return;
    }

    final bool? guardado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DialogoEditarEmpresa(
        empresa: empresa,
        onGuardar:
            ({
              required email,
              required telefono,
              required cif,
              required calle,
              required codigoPostal,
              required ciudad,
              required pais,
            }) {
              return vmAjustes.actualizarEmpresa(
                email: email,
                telefono: telefono,
                cif: cif,
                calle: calle,
                codigoPostal: codigoPostal,
                ciudad: ciudad,
                pais: pais,
              );
            },
      ),
    );

    if (!context.mounted || guardado != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Empresa actualizada')));
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
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                const CabeceraTituloGrande(titulo: 'Ajustes'),
              ],
              body: _CuerpoAjustes(
            vmAjustes: vmAjustes,
            onCambiarPin: () => _mostrarDialogoCambiarPin(context),
            onCambiarContrasena: () =>
                _mostrarDialogoCambiarContrasena(context, vmAjustes),
            onEditarEmpresa: () =>
                _mostrarDialogoEditarEmpresa(context, vmAjustes),
          ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CuerpoAjustes extends StatelessWidget {
  const _CuerpoAjustes({
    required this.vmAjustes,
    required this.onCambiarPin,
    required this.onCambiarContrasena,
    required this.onEditarEmpresa,
  });

  final ViewModelAdminAjustes vmAjustes;
  final VoidCallback onCambiarPin;
  final VoidCallback onCambiarContrasena;
  final VoidCallback onEditarEmpresa;

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
      return EstadoCentrado(
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
            accion: IconButton(
              tooltip: 'Editar empresa',
              icon: const Icon(Icons.edit_outlined),
              onPressed: vmAjustes.cargando || vmAjustes.empresa == null
                  ? null
                  : onEditarEmpresa,
            ),
            children: _filasEmpresa(vmAjustes.empresa),
          ),
          const SizedBox(height: 28),
          _Seccion(
            titulo: 'TEMA',
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
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Cambiar PIN'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onCambiarPin,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Cambiar contraseña'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onCambiarContrasena,
                ),
              ],
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
              onTap: () async {
                final bool ok = await context
                    .read<ViewModelAutenticacion>()
                    .cerrarSesion();
                if (!context.mounted || !ok) return;
                GestorNavegacion.irACerrarSesion(context);
              },
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            AvisoError(mensaje: error),
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
          etiqueta: 'Tema',
          valor: '-',
        ),
      ];
    }
    return <Widget>[
      _FilaLogo(
        icono: Icons.image_outlined,
        etiqueta: 'Logo',
        logoUrl: visual.logoUrl,
      ),
      _FilaColor(
        icono: Icons.format_color_fill_outlined,
        etiqueta: 'Color primario',
        valor: visual.colorPrimario,
      ),
      _FilaColor(
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
    ];
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.children, this.accion});

  final String titulo;
  final List<Widget> children;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ?accion,
          ],
        ),
        SizedBox(height: accion == null ? 8 : 4),
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

typedef _GuardarEmpresa =
    Future<bool> Function({
      required String email,
      required String telefono,
      required String cif,
      required String calle,
      required String codigoPostal,
      required String ciudad,
      required String pais,
    });

class _DialogoEditarEmpresa extends StatefulWidget {
  const _DialogoEditarEmpresa({required this.empresa, required this.onGuardar});

  final DtoAjustesEmpresaAdmin empresa;
  final _GuardarEmpresa onGuardar;

  @override
  State<_DialogoEditarEmpresa> createState() => _DialogoEditarEmpresaState();
}

class _DialogoEditarEmpresaState extends State<_DialogoEditarEmpresa> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrlEmail;
  late final TextEditingController _ctrlTelefono;
  late final TextEditingController _ctrlCif;
  late final TextEditingController _ctrlCalle;
  late final TextEditingController _ctrlCodigoPostal;
  late final TextEditingController _ctrlCiudad;
  late final TextEditingController _ctrlPais;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final DtoAjustesEmpresaAdmin empresa = widget.empresa;
    _ctrlEmail = TextEditingController(text: empresa.email);
    _ctrlTelefono = TextEditingController(
      text: _limpiarFallback(empresa.telefono, 'Sin teléfono'),
    );
    _ctrlCif = TextEditingController(
      text: _limpiarFallback(empresa.cif, 'Sin CIF'),
    );
    _ctrlCalle = TextEditingController(text: empresa.calle);
    _ctrlCodigoPostal = TextEditingController(text: empresa.codigoPostal);
    _ctrlCiudad = TextEditingController(text: empresa.ciudad);
    _ctrlPais = TextEditingController(text: empresa.pais);
  }

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlTelefono.dispose();
    _ctrlCif.dispose();
    _ctrlCalle.dispose();
    _ctrlCodigoPostal.dispose();
    _ctrlCiudad.dispose();
    _ctrlPais.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _guardando = true);
    final bool ok = await widget.onGuardar(
      email: _ctrlEmail.text,
      telefono: _ctrlTelefono.text,
      cif: _ctrlCif.text,
      calle: _ctrlCalle.text,
      codigoPostal: _ctrlCodigoPostal.text,
      ciudad: _ctrlCiudad.text,
      pais: _ctrlPais.text,
    );

    if (!mounted) {
      return;
    }
    setState(() => _guardando = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la empresa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return AlertDialog(
      title: const Text('Editar empresa'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: widget.empresa.nombre,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: espaciado.radioInput,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFormulario(
                  controller: _ctrlEmail,
                  etiqueta: 'Email *',
                  teclado: TextInputType.emailAddress,
                  validador: (valor) {
                    final String limpio = valor?.trim() ?? '';
                    if (limpio.isEmpty) {
                      return 'El email es obligatorio';
                    }
                    if (!limpio.contains('@')) {
                      return 'El email no parece válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CampoFormulario(
                  controller: _ctrlTelefono,
                  etiqueta: 'Teléfono',
                  teclado: TextInputType.phone,
                  formateadores: Validadores.telefono,
                  validador: (valor) => Validadores.telefonoValidador(valor),
                ),
                const SizedBox(height: 12),
                CampoFormulario(controller: _ctrlCif, etiqueta: 'CIF'),
                const SizedBox(height: 12),
                CampoFormulario(controller: _ctrlCalle, etiqueta: 'Calle'),
                const SizedBox(height: 12),
                CampoFormulario(
                  controller: _ctrlCodigoPostal,
                  etiqueta: 'Código postal',
                ),
                const SizedBox(height: 12),
                CampoFormulario(controller: _ctrlCiudad, etiqueta: 'Ciudad'),
                const SizedBox(height: 12),
                CampoFormulario(
                  controller: _ctrlPais,
                  etiqueta: 'País *',
                  textCapitalization: TextCapitalization.characters,
                  validador: (valor) {
                    final String limpio = valor?.trim() ?? '';
                    if (limpio.isEmpty) {
                      return 'El país es obligatorio';
                    }
                    if (limpio.length != 2) {
                      return 'Usa el código de 2 letras';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  String _limpiarFallback(String valor, String fallback) {
    return valor == fallback ? '' : valor;
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

class _FilaLogo extends StatelessWidget {
  const _FilaLogo({
    required this.icono,
    required this.etiqueta,
    required this.logoUrl,
  });

  final IconData icono;
  final String etiqueta;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool tieneLogo = logoUrl.startsWith('http');

    return ListTile(
      leading: Icon(icono, color: colorScheme.outline),
      title: Text(
        etiqueta,
        style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
      ),
      subtitle: tieneLogo
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logoUrl,
                    width: 96,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Text(
                      'No se pudo cargar el logo',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            )
          : Text('Sin logo', style: textTheme.bodyLarge),
    );
  }
}

class _FilaColor extends StatelessWidget {
  const _FilaColor({
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
    final Color? color = _parseColor(valor);

    return ListTile(
      leading: Icon(icono, color: colorScheme.outline),
      title: Text(
        etiqueta,
        style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(valor, style: textTheme.bodyLarge)),
          if (color != null) ...[
            const SizedBox(width: 10),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color? _parseColor(String valor) {
    final String normalizado = valor.trim();
    if (normalizado.isEmpty || normalizado.startsWith('Color ')) {
      return null;
    }
    final String hex = normalizado.startsWith('#')
        ? normalizado.substring(1)
        : normalizado.replaceFirst('0x', '').replaceFirst('0X', '');
    final String conAlpha = hex.length == 6 ? 'FF$hex' : hex;
    if (conAlpha.length != 8) {
      return null;
    }
    final int? parsed = int.tryParse(conAlpha, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
}

