import 'dart:typed_data';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/aviso_error.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/campo_formulario.dart';
import 'package:citaria_frontend/ui/widgets/chip_habilidad.dart';
import 'package:citaria_frontend/ui/widgets/imagen_servicio_editable.dart';
import 'package:citaria_frontend/ui/utils/validadores.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Pantalla de formulario de alta de nuevo servicio.
class PantallaAdminNuevoServicio extends StatefulWidget {
  const PantallaAdminNuevoServicio({super.key});

  @override
  State<PantallaAdminNuevoServicio> createState() =>
      _PantallaAdminNuevoServicioState();
}

class _PantallaAdminNuevoServicioState
    extends State<PantallaAdminNuevoServicio> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlNombre = TextEditingController();
  final _ctrlDescripcion = TextEditingController();
  final _ctrlPrecio = TextEditingController();
  final Set<int> _habilidadesSeleccionadas = <int>{};
  late final ViewModelAdminCatalogo _viewModel;
  int? _categoriaSeleccionadaId;
  int _duracionHoras = 0;
  int _duracionMinutos = 30;
  Uint8List? _imagenBytes;
  String _imagenNombre = 'imagen.jpg';

  static const List<int> _opcionesMinutos = [
    0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55,
  ];

  int get _duracionTotalMinutos => _duracionHoras * 60 + _duracionMinutos;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminCatalogo(
      repoCatalogo: context.read<RepoCatalogo>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    )..cargarFormularioNuevoServicio();
  }

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlDescripcion.dispose();
    _ctrlPrecio.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null || !mounted) return;
    final bytes = await imagen.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imagenBytes = bytes;
      _imagenNombre = imagen.name;
    });
  }

  Future<void> _crearServicio() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_duracionTotalMinutos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La duración debe ser mayor que 0.')),
      );
      return;
    }

    final servicio = await _viewModel.crearServicio(
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
      precio: _ctrlPrecio.text,
      duracion: _duracionTotalMinutos.toString(),
      categoriaId: _categoriaSeleccionadaId,
      habilidadIds: _habilidadesSeleccionadas,
    );

    if (!mounted) return;

    if (servicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear el servicio.'),
        ),
      );
      return;
    }

    final int? servicioId = servicio.id;
    if (_imagenBytes != null && servicioId != null) {
      await _viewModel.subirImagenServicio(
        id: servicioId,
        bytes: _imagenBytes!,
        nombreFichero: _imagenNombre,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Servicio creado')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) => _ContenidoNuevoServicio(
          formKey: _formKey,
          ctrlNombre: _ctrlNombre,
          ctrlDescripcion: _ctrlDescripcion,
          ctrlPrecio: _ctrlPrecio,
          duracionHoras: _duracionHoras,
          duracionMinutos: _duracionMinutos,
          opcionesMinutos: _opcionesMinutos,
          categoriaSeleccionadaId: _categoriaSeleccionadaId,
          habilidadesSeleccionadas: _habilidadesSeleccionadas,
          vmCatalogo: vmCatalogo,
          onCrear: _crearServicio,
          onCategoriaChanged: (id) =>
              setState(() => _categoriaSeleccionadaId = id),
          onHorasChanged: (h) => setState(() => _duracionHoras = h),
          onMinutosChanged: (m) => setState(() => _duracionMinutos = m),
          onHabilidadTap: _alternarHabilidad,
          onEditarImagen: _seleccionarImagen,
          imagenBytes: _imagenBytes,
        ),
      ),
    );
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
}

class _ContenidoNuevoServicio extends StatelessWidget {
  const _ContenidoNuevoServicio({
    required this.formKey,
    required this.ctrlNombre,
    required this.ctrlDescripcion,
    required this.ctrlPrecio,
    required this.duracionHoras,
    required this.duracionMinutos,
    required this.opcionesMinutos,
    required this.categoriaSeleccionadaId,
    required this.habilidadesSeleccionadas,
    required this.vmCatalogo,
    required this.onCrear,
    required this.onCategoriaChanged,
    required this.onHorasChanged,
    required this.onMinutosChanged,
    required this.onHabilidadTap,
    required this.onEditarImagen,
    required this.imagenBytes,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlDescripcion;
  final TextEditingController ctrlPrecio;
  final int duracionHoras;
  final int duracionMinutos;
  final List<int> opcionesMinutos;
  final int? categoriaSeleccionadaId;
  final Set<int> habilidadesSeleccionadas;
  final ViewModelAdminCatalogo vmCatalogo;
  final VoidCallback onCrear;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<int> onHorasChanged;
  final ValueChanged<int> onMinutosChanged;
  final ValueChanged<int> onHabilidadTap;
  final VoidCallback onEditarImagen;
  final Uint8List? imagenBytes;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool cargandoInicial =
        vmCatalogo.cargando &&
        vmCatalogo.categorias.isEmpty &&
        vmCatalogo.habilidades.isEmpty;

    return Scaffold(
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: vmCatalogo.cargando || cargandoInicial ? null : onCrear,
            child: vmCatalogo.cargando && !cargandoInicial
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear servicio'),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Nuevo servicio'),
          ],
          body: cargandoInicial
              ? const Center(child: CircularProgressIndicator())
              : Form(
              key: formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  24,
                  espaciado.padX,
                  120,
                ),
                children: [
                  if (vmCatalogo.error != null) ...[
                    AvisoError(
                      mensaje: vmCatalogo.error!,
                      onReintentar: vmCatalogo.cargarFormularioNuevoServicio,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Imagen
                  Center(
                    child: ImagenServicioEditable(
                      imagenUrl: null,
                      espaciado: espaciado,
                      colorScheme: colorScheme,
                      onEditar: onEditarImagen,
                      imagenLocalBytes: imagenBytes,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Campos de texto
                  CampoFormulario(
                    controller: ctrlNombre,
                    etiqueta: 'Nombre *',
                    formateadores: Validadores.nombreCatalogo,
                    validador: (v) => Validadores.obligatorioValidador(v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ctrlDescripcion,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: espaciado.radioInput,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: ctrlPrecio,
                    etiqueta: 'Precio *',
                    teclado: const TextInputType.numberWithOptions(decimal: true),
                    formateadores: Validadores.precio,
                    validador: Validadores.precioValidador,
                  ),
                  const SizedBox(height: 16),

                  // Duración
                  Text(
                    'Duración *',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
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
                            for (final m in opcionesMinutos)
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

                  // Categoría
                  DropdownButtonFormField<int>(
                    key: ValueKey('categoria-$categoriaSeleccionadaId'),
                    initialValue: categoriaSeleccionadaId,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: espaciado.radioInput,
                      ),
                    ),
                    items: [
                      for (final categoria in vmCatalogo.categorias)
                        DropdownMenuItem<int>(
                          value: categoria.id,
                          child: Text(categoria.nombre),
                        ),
                    ],
                    onChanged: onCategoriaChanged,
                  ),
                  const SizedBox(height: 28),

                  // Habilidades
                  Text(
                    'HABILIDADES REQUERIDAS',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (vmCatalogo.habilidades.isEmpty)
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
                        for (final habilidad in vmCatalogo.habilidades)
                          ChipHabilidad(
                            etiqueta: habilidad.nombre,
                            seleccionado: habilidadesSeleccionadas.contains(
                              habilidad.id,
                            ),
                            onTap: () => onHabilidadTap(habilidad.id),
                          ),
                      ],
                    ),
                ],
              ),
            ),
        ),
      ),
    );
  }

}
