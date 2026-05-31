import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/chip_habilidad.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/imagen_servicio_editable.dart';
import 'package:citaria_frontend/ui/utils/validadores.dart';
import 'package:citaria_frontend/dto/admin/dto_detalle_servicio_catalogo_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_categoria_catalogo_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_habilidad_catalogo_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PantallaAdminDetalleServicio extends StatefulWidget {
  const PantallaAdminDetalleServicio({super.key, required this.id});

  final int id;

  @override
  State<PantallaAdminDetalleServicio> createState() =>
      _PantallaAdminDetalleServicioState();
}

class _PantallaAdminDetalleServicioState
    extends State<PantallaAdminDetalleServicio> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlDescripcion = TextEditingController();
  final _ctrlPrecio = TextEditingController();
  final Set<int> _habilidadesSeleccionadas = <int>{};
  late final ViewModelAdminCatalogo _viewModel;
  int? _categoriaSeleccionadaId;
  bool _activo = true;
  bool _sincronizado = false;

  // Duración: horas (0–8) y minutos (0, 5, 10, …, 55)
  int _duracionHoras = 0;
  int _duracionMinutos = 30;

  int get _duracionTotalMinutos => _duracionHoras * 60 + _duracionMinutos;

  static const List<int> _opcionesMinutos = [
    0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55,
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarDetalleServicio(widget.id);
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlDescripcion.dispose();
    _ctrlPrecio.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _sincronizarDetalle(DtoDetalleServicioCatalogoAdmin detalle) {
    _ctrlNombre.text = detalle.nombre;
    _ctrlDescripcion.text = detalle.descripcion;
    _ctrlPrecio.text = detalle.precio.toStringAsFixed(2);
    _categoriaSeleccionadaId = detalle.categoriaId;
    _activo = detalle.activo;
    _habilidadesSeleccionadas
      ..clear()
      ..addAll(detalle.habilidadIds);
    // Descomponer minutos totales en horas + minutos redondeados a 5
    final int total = detalle.duracionMinutos;
    _duracionHoras = total ~/ 60;
    final int restoMin = total % 60;
    _duracionMinutos = _opcionesMinutos.reduce(
      (prev, curr) =>
          (curr - restoMin).abs() < (prev - restoMin).abs() ? curr : prev,
    );
    _sincronizado = true;
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_duracionTotalMinutos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La duración debe ser mayor que 0.')),
      );
      return;
    }

    final servicio = await _viewModel.actualizarServicio(
      id: widget.id,
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
      precio: _ctrlPrecio.text,
      duracion: _duracionTotalMinutos.toString(),
      categoriaId: _categoriaSeleccionadaId,
      activo: _activo,
      habilidadIds: _habilidadesSeleccionadas,
    );

    if (!mounted) return;
    if (servicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.error ?? 'No se pudo guardar.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio guardado')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _desactivar() async {
    final bool ok = await _viewModel.desactivarServicio(widget.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo desactivar.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio desactivado')),
    );
    Navigator.pop(context, true);
  }

  void _alternarHabilidad(int id) {
    setState(() {
      if (_habilidadesSeleccionadas.contains(id)) {
        _habilidadesSeleccionadas.remove(id);
      } else {
        _habilidadesSeleccionadas.add(id);
      }
    });
  }

  Future<void> _editarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null || !mounted) return;

    final List<int> bytes = await imagen.readAsBytes();
    if (!mounted) return;
    final bool ok = await _viewModel.subirImagenServicio(
      id: widget.id,
      bytes: bytes,
      nombreFichero: imagen.name,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.error ?? 'No se pudo subir la imagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) {
          final detalle = vmCatalogo.detalleServicio;
          if (detalle != null && !_sincronizado) {
            _sincronizarDetalle(detalle);
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
                  const CabeceraTituloGrande(titulo: 'Servicio'),
                ],
                body: _CuerpoDetalleServicio(
              detalle: detalle,
              cargando: vmCatalogo.cargando,
              error: vmCatalogo.error,
              espaciado: espaciado,
              formKey: _formKey,
              ctrlNombre: _ctrlNombre,
              ctrlDescripcion: _ctrlDescripcion,
              ctrlPrecio: _ctrlPrecio,
              duracionHoras: _duracionHoras,
              duracionMinutos: _duracionMinutos,
              categorias: vmCatalogo.categorias,
              habilidades: vmCatalogo.habilidades,
              categoriaSeleccionadaId: _categoriaSeleccionadaId,
              habilidadesSeleccionadas: _habilidadesSeleccionadas,
              activo: _activo,
              onCategoriaChanged: (id) =>
                  setState(() => _categoriaSeleccionadaId = id),
              onHabilidadTap: _alternarHabilidad,
              onActivoChanged: (valor) => setState(() => _activo = valor),
              onHorasChanged: (h) => setState(() => _duracionHoras = h),
              onMinutosChanged: (m) => setState(() => _duracionMinutos = m),
              onReintentar: () => vmCatalogo.cargarDetalleServicio(widget.id),
              onDesactivar: detalle == null ? null : _desactivar,
              onEditarImagen: _editarImagen,
            ),
                ),
              ),
          );
        },
      ),
    );
  }
}

// Cuerpo

class _CuerpoDetalleServicio extends StatelessWidget {
  const _CuerpoDetalleServicio({
    required this.detalle,
    required this.cargando,
    required this.error,
    required this.espaciado,
    required this.formKey,
    required this.ctrlNombre,
    required this.ctrlDescripcion,
    required this.ctrlPrecio,
    required this.duracionHoras,
    required this.duracionMinutos,
    required this.categorias,
    required this.habilidades,
    required this.categoriaSeleccionadaId,
    required this.habilidadesSeleccionadas,
    required this.activo,
    required this.onCategoriaChanged,
    required this.onHabilidadTap,
    required this.onActivoChanged,
    required this.onHorasChanged,
    required this.onMinutosChanged,
    required this.onReintentar,
    required this.onDesactivar,
    required this.onEditarImagen,
  });

  final DtoDetalleServicioCatalogoAdmin? detalle;
  final bool cargando;
  final String? error;
  final EspaciadoCitaria espaciado;
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlDescripcion;
  final TextEditingController ctrlPrecio;
  final int duracionHoras;
  final int duracionMinutos;
  final List<DtoCategoriaCatalogoAdmin> categorias;
  final List<DtoHabilidadCatalogoAdmin> habilidades;
  final int? categoriaSeleccionadaId;
  final Set<int> habilidadesSeleccionadas;
  final bool activo;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<int> onHabilidadTap;
  final ValueChanged<bool> onActivoChanged;
  final ValueChanged<int> onHorasChanged;
  final ValueChanged<int> onMinutosChanged;
  final VoidCallback onReintentar;
  final VoidCallback? onDesactivar;
  final VoidCallback onEditarImagen;

  static const List<int> _opcionesMinutos = [
    0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
        mensaje: 'No se ha encontrado el servicio.',
        accionTexto: 'Reintentar',
        onAccion: onReintentar,
      );
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 120),
        children: [
          // Imagen
          Center(
            child: ImagenServicioEditable(
              imagenUrl: detalle!.imagenUrl,
              espaciado: espaciado,
              colorScheme: colorScheme,
              onEditar: onEditarImagen,
            ),
          ),
          const SizedBox(height: 24),

          // Campos de texto
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
          TextFormField(
            controller: ctrlPrecio,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: Validadores.precio,
            validator: Validadores.precioValidador,
            decoration: InputDecoration(
              labelText: 'Precio *',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
          ),
          const SizedBox(height: 16),

          // Duración
          Text(
            'Duración *',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey('horas-$duracionHoras'),
                  initialValue: duracionHoras,
                  decoration: InputDecoration(
                    labelText: 'Horas',
                    border: OutlineInputBorder(
                      borderRadius: espaciado.radioInput,
                    ),
                  ),
                  items: [
                    for (int h = 0; h <= 8; h++)
                      DropdownMenuItem(
                        value: h,
                        child: Text('$h h'),
                      ),
                  ],
                  onChanged: (h) {
                    if (h != null) onHorasChanged(h);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey('minutos-$duracionMinutos'),
                  initialValue: duracionMinutos,
                  decoration: InputDecoration(
                    labelText: 'Minutos',
                    border: OutlineInputBorder(
                      borderRadius: espaciado.radioInput,
                    ),
                  ),
                  items: [
                    for (final m in _opcionesMinutos)
                      DropdownMenuItem(
                        value: m,
                        child: Text('$m min'),
                      ),
                  ],
                  onChanged: (m) {
                    if (m != null) onMinutosChanged(m);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categoría + activo
          DropdownButtonFormField<int>(
            key: ValueKey('categoria-$categoriaSeleccionadaId'),
            initialValue: categoriaSeleccionadaId,
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
            items: [
              for (final categoria in categorias)
                DropdownMenuItem<int>(
                  value: categoria.id,
                  child: Text(categoria.nombre),
                ),
            ],
            onChanged: onCategoriaChanged,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: activo,
            onChanged: onActivoChanged,
            title: const Text('Activo'),
            contentPadding: EdgeInsets.zero,
          ),

          // Habilidades
          const SizedBox(height: 24),
          Text(
            'HABILIDADES REQUERIDAS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (habilidades.isEmpty)
            Text(
              'Sin habilidades disponibles',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final habilidad in habilidades)
                  ChipHabilidad(
                    etiqueta: habilidad.nombre,
                    seleccionado: habilidadesSeleccionadas.contains(habilidad.id),
                    onTap: () => onHabilidadTap(habilidad.id),
                  ),
              ],
            ),

          // Desactivar
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
            onPressed: onDesactivar,
            child: const Text('Desactivar servicio'),
          ),
        ],
      ),
    );
  }

}

