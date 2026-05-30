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

class PantallaAdminDetalleHabilidad extends StatefulWidget {
  const PantallaAdminDetalleHabilidad({super.key, required this.id});

  final int id;

  @override
  State<PantallaAdminDetalleHabilidad> createState() =>
      _PantallaAdminDetalleHabilidadState();
}

class _PantallaAdminDetalleHabilidadState extends State<PantallaAdminDetalleHabilidad> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlDescripcion = TextEditingController();
  late final ViewModelAdminCatalogo _viewModel;
  bool _activo = true;
  bool _sincronizado = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarDetalleHabilidad(widget.id);
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlDescripcion.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final habilidad = await _viewModel.actualizarHabilidad(
      id: widget.id,
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
      activo: _activo,
    );

    if (!mounted) {
      return;
    }

    if (habilidad == null) {
      _mostrarError('No se pudo guardar la habilidad.');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habilidad guardada')));
    Navigator.pop(context, true);
  }

  Future<void> _desactivar() async {
    final bool ok = await _viewModel.desactivarHabilidad(widget.id);
    if (!mounted) {
      return;
    }
    if (!ok) {
      _mostrarError('No se pudo desactivar la habilidad.');
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habilidad desactivada')));
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
          final detalle = vmCatalogo.detalleHabilidad;
          if (detalle != null && !_sincronizado) {
            _ctrlNombre.text = detalle.nombre;
            _ctrlDescripcion.text = detalle.descripcion == 'Sin descripción'
                ? ''
                : detalle.descripcion;
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
                  const CabeceraTituloGrande(titulo: 'Habilidad'),
                ],
                body: _CuerpoDetalleHabilidad(
                  detalle: detalle,
                  cargando: vmCatalogo.cargando,
                  error: vmCatalogo.error,
                  espaciado: espaciado,
                  formKey: _formKey,
                  ctrlNombre: _ctrlNombre,
                  ctrlDescripcion: _ctrlDescripcion,
                  activo: _activo,
                  onActivoChanged: (valor) => setState(() => _activo = valor),
                  onReintentar: () => vmCatalogo.cargarDetalleHabilidad(widget.id),
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

class _CuerpoDetalleHabilidad extends StatelessWidget {
  const _CuerpoDetalleHabilidad({
    required this.detalle,
    required this.cargando,
    required this.error,
    required this.espaciado,
    required this.formKey,
    required this.ctrlNombre,
    required this.ctrlDescripcion,
    required this.activo,
    required this.onActivoChanged,
    required this.onReintentar,
    required this.onDesactivar,
  });

  final DtoHabilidadCatalogoAdmin? detalle;
  final bool cargando;
  final String? error;
  final EspaciadoCitaria espaciado;
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlDescripcion;
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
        mensaje: 'No se ha encontrado la habilidad.',
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
          TextFormField(
            controller: ctrlDescripcion,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción',
              alignLabelWithHint: true,
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
            child: const Text('Desactivar habilidad'),
          ),
        ],
      ),
    );
  }
}

