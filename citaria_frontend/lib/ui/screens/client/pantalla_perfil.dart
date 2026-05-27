import 'package:citaria_frontend/ui/widgets/avatar_editable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  _CampoPerfil? _campoEnEdicion;
  final TextEditingController _controladorEdicion = TextEditingController();

  @override
  void dispose() {
    _controladorEdicion.dispose();
    super.dispose();
  }

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
    final bool ok = await context.read<ViewModelPerfilCliente>().cerrarSesion();
    if (!mounted) return;
    if (ok) {
      GestorNavegacion.irACerrarSesion(context);
      return;
    }
    final String mensaje =
        context.read<ViewModelPerfilCliente>().error ??
        'No se ha podido cerrar la sesión.';
    _mostrarMensaje(mensaje);
  }

  void _editarCampo(_CampoPerfil campo, String valor) {
    setState(() {
      _campoEnEdicion = campo;
      _controladorEdicion.text = valor == 'No indicado' ? '' : valor;
      _controladorEdicion.selection = TextSelection.fromPosition(
        TextPosition(offset: _controladorEdicion.text.length),
      );
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _campoEnEdicion = null;
      _controladorEdicion.clear();
    });
  }

  Future<void> _guardarCampo(DtoPerfilCliente perfil) async {
    final _CampoPerfil? campo = _campoEnEdicion;
    if (campo == null) return;

    final String valor = _controladorEdicion.text.trim();
    if (campo == _CampoPerfil.nombre && valor.isEmpty) {
      _mostrarMensaje('El nombre es obligatorio.');
      return;
    }

    final bool ok = await context
        .read<ViewModelPerfilCliente>()
        .actualizarDatos(
          nombre: campo == _CampoPerfil.nombre ? valor : perfil.nombre,
          apellidos: campo == _CampoPerfil.apellidos ? valor : perfil.apellidos,
          telefono: campo == _CampoPerfil.telefono ? valor : perfil.telefono,
        );

    if (!mounted) return;
    if (ok) {
      _cancelarEdicion();
    } else {
      final String mensaje =
          context.read<ViewModelPerfilCliente>().error ??
          'No se han podido guardar los cambios.';
      _mostrarMensaje(mensaje);
    }
  }

  Future<void> _editarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null || !mounted) return;

    final List<int> bytes = await imagen.readAsBytes();
    if (!mounted) return;
    final bool ok = await context
        .read<ViewModelPerfilCliente>()
        .subirFoto(bytes: bytes, nombreFichero: imagen.name);

    if (!mounted) return;
    if (!ok) {
      _mostrarMensaje(
        context.read<ViewModelPerfilCliente>().error ??
            'No se pudo subir la foto.',
      );
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final perfilVm = context.watch<ViewModelPerfilCliente>();
    final perfil = perfilVm.datos;

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
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        AvatarEditable(
                          texto: perfil.nombreCompleto,
                          fotoUrl: perfil.fotoUrl,
                          tamano: 88,
                          radio: 44,
                          cargando: perfilVm.guardando,
                          onEditar: _editarFoto,
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
                          campo: _CampoPerfil.nombre,
                          campoEnEdicion: _campoEnEdicion,
                          controller: _controladorEdicion,
                          guardando: perfilVm.guardando,
                          onEditar: () =>
                              _editarCampo(_CampoPerfil.nombre, perfil.nombre),
                          onGuardar: () => _guardarCampo(perfil),
                          onCancelar: _cancelarEdicion,
                        ),
                        const _Divisor(),
                        _FilaDato(
                          icono: Icons.badge_outlined,
                          label: 'Apellidos',
                          valor: perfil.apellidos,
                          campo: _CampoPerfil.apellidos,
                          campoEnEdicion: _campoEnEdicion,
                          controller: _controladorEdicion,
                          guardando: perfilVm.guardando,
                          onEditar: () => _editarCampo(
                            _CampoPerfil.apellidos,
                            perfil.apellidos,
                          ),
                          onGuardar: () => _guardarCampo(perfil),
                          onCancelar: _cancelarEdicion,
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
                          campo: _CampoPerfil.telefono,
                          campoEnEdicion: _campoEnEdicion,
                          controller: _controladorEdicion,
                          guardando: perfilVm.guardando,
                          onEditar: () => _editarCampo(
                            _CampoPerfil.telefono,
                            perfil.telefono,
                          ),
                          onGuardar: () => _guardarCampo(perfil),
                          onCancelar: _cancelarEdicion,
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

enum _CampoPerfil { nombre, apellidos, telefono }

class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.icono,
    required this.label,
    required this.valor,
    this.campo,
    this.campoEnEdicion,
    this.controller,
    this.guardando = false,
    this.onEditar,
    this.onGuardar,
    this.onCancelar,
  });

  final IconData icono;
  final String label;
  final String valor;
  final _CampoPerfil? campo;
  final _CampoPerfil? campoEnEdicion;
  final TextEditingController? controller;
  final bool guardando;
  final VoidCallback? onEditar;
  final VoidCallback? onGuardar;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool editable = campo != null;
    final bool editando = editable && campoEnEdicion == campo;

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
                if (editando)
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: campo == _CampoPerfil.telefono
                        ? TextInputType.phone
                        : TextInputType.text,
                    textInputAction: TextInputAction.done,
                    enabled: !guardando,
                    onFieldSubmitted: (_) => onGuardar?.call(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(valor, style: textTheme.bodyLarge),
              ],
            ),
          ),
          if (editando) ...[
            IconButton(
              tooltip: 'Cancelar',
              icon: Icon(Icons.close, color: colorScheme.outline, size: 20),
              onPressed: guardando ? null : onCancelar,
            ),
            IconButton(
              tooltip: 'Guardar $label',
              icon: guardando
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.check, color: colorScheme.primary, size: 20),
              onPressed: guardando ? null : onGuardar,
            ),
          ] else if (editable)
            Semantics(
              label: 'Editar $label',
              child: IconButton(
                tooltip: 'Editar $label',
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.outline,
                  size: 18,
                ),
                onPressed: onEditar,
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
