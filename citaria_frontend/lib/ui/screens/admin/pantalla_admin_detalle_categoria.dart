import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/ui/utils/validadores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PantallaAdminDetalleCategoria extends StatefulWidget {
  const PantallaAdminDetalleCategoria({super.key, required this.id});

  final int id;

  @override
  State<PantallaAdminDetalleCategoria> createState() =>
      _PantallaAdminDetalleCategoriaState();
}

class _PantallaAdminDetalleCategoriaState
    extends State<PantallaAdminDetalleCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  late final ViewModelAdminCatalogo _viewModel;
  bool _activo = true;
  bool _sincronizado = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarDetalleCategoria(widget.id);
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final categoria = await _viewModel.actualizarCategoria(
      id: widget.id,
      nombre: _ctrlNombre.text,
      activo: _activo,
    );

    if (!mounted) {
      return;
    }

    if (categoria == null) {
      _mostrarError('No se pudo guardar la categoría.');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Categoría guardada')));
    Navigator.pop(context, true);
  }

  Future<void> _desactivar() async {
    final bool ok = await _viewModel.desactivarCategoria(widget.id);
    if (!mounted) {
      return;
    }
    if (!ok) {
      _mostrarError('No se pudo desactivar la categoría.');
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Categoría desactivada')));
    Navigator.pop(context, true);
  }

  void _mostrarError(String fallback) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.error ?? fallback)));
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) {
          final detalle = vmCatalogo.detalleCategoria;
          if (detalle != null && !_sincronizado) {
            _ctrlNombre.text = detalle.nombre;
            _activo = detalle.activo;
            _sincronizado = true;
          }

          return Scaffold(
            bottomNavigationBar: BarraCtaFija(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vmCatalogo.cargando || detalle == null
                      ? null
                      : _guardar,
                  child: vmCatalogo.cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: NestedScrollView(
                headerSliverBuilder: (_, _) => [
                  const CabeceraTituloGrande(titulo: 'Categoría'),
                ],
                body: _CuerpoDetalleCategoria(
                  detalle: detalle,
                  cargando: vmCatalogo.cargando,
                  error: vmCatalogo.error,
                  espaciado: espaciado,
                  formKey: _formKey,
                  ctrlNombre: _ctrlNombre,
                  activo: _activo,
                  onActivoChanged: (valor) => setState(() => _activo = valor),
                  onReintentar: () =>
                      vmCatalogo.cargarDetalleCategoria(widget.id),
                  onDesactivar: detalle == null ? null : _desactivar,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CuerpoDetalleCategoria extends StatelessWidget {
  const _CuerpoDetalleCategoria({
    required this.detalle,
    required this.cargando,
    required this.error,
    required this.espaciado,
    required this.formKey,
    required this.ctrlNombre,
    required this.activo,
    required this.onActivoChanged,
    required this.onReintentar,
    required this.onDesactivar,
  });

  final DtoCategoriaCatalogoAdmin? detalle;
  final bool cargando;
  final String? error;
  final EspaciadoCitaria espaciado;
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final bool activo;
  final ValueChanged<bool> onActivoChanged;
  final VoidCallback onReintentar;
  final VoidCallback? onDesactivar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && detalle == null) {
      return EstadoCentrado(
        mensaje: error!,
        accionTexto: 'Reintentar',
        onAccion: onReintentar,
      );
    }
    if (detalle == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado la categoría.',
        accionTexto: 'Reintentar',
        onAccion: onReintentar,
      );
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 120),
        children: [
          TextFormField(
            controller: ctrlNombre,
            inputFormatters: Validadores.nombreCatalogo,
            validator: (valor) => Validadores.obligatorioValidador(valor),
            decoration: InputDecoration(
              labelText: 'Nombre *',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: activo,
            onChanged: onActivoChanged,
            title: const Text('Activa'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
            onPressed: onDesactivar,
            child: const Text('Desactivar categoría'),
          ),
        ],
      ),
    );
  }
}

