import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P32 — Formulario de alta de nuevo servicio.
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
  final _ctrlDuracion = TextEditingController();
  final Set<int> _skillsSeleccionadas = <int>{};
  late final ViewModelAdminCatalogo _viewModel;
  int? _categoriaSeleccionadaId;

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
    _ctrlDuracion.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _crearServicio() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final servicio = await _viewModel.crearServicio(
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
      precio: _ctrlPrecio.text,
      duracion: _ctrlDuracion.text,
      categoriaId: _categoriaSeleccionadaId,
      skillIds: _skillsSeleccionadas,
    );

    if (!mounted) {
      return;
    }

    if (servicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear el servicio.'),
        ),
      );
      return;
    }

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
          ctrlDuracion: _ctrlDuracion,
          categoriaSeleccionadaId: _categoriaSeleccionadaId,
          skillsSeleccionadas: _skillsSeleccionadas,
          vmCatalogo: vmCatalogo,
          onCrear: _crearServicio,
          onCategoriaChanged: (id) =>
              setState(() => _categoriaSeleccionadaId = id),
          onSkillTap: _alternarSkill,
        ),
      ),
    );
  }

  void _alternarSkill(int id) {
    setState(() {
      if (_skillsSeleccionadas.contains(id)) {
        _skillsSeleccionadas.remove(id);
      } else {
        _skillsSeleccionadas.add(id);
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
    required this.ctrlDuracion,
    required this.categoriaSeleccionadaId,
    required this.skillsSeleccionadas,
    required this.vmCatalogo,
    required this.onCrear,
    required this.onCategoriaChanged,
    required this.onSkillTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlDescripcion;
  final TextEditingController ctrlPrecio;
  final TextEditingController ctrlDuracion;
  final int? categoriaSeleccionadaId;
  final Set<int> skillsSeleccionadas;
  final ViewModelAdminCatalogo vmCatalogo;
  final VoidCallback onCrear;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<int> onSkillTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool cargandoInicial =
        vmCatalogo.cargando &&
        vmCatalogo.categorias.isEmpty &&
        vmCatalogo.skills.isEmpty;

    return Scaffold(
      appBar: const CabeceraPantalla(
        titulo: 'Nuevo servicio',
        mostrarAtras: true,
      ),
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
                    _AvisoError(
                      mensaje: vmCatalogo.error!,
                      onReintentar: vmCatalogo.cargarFormularioNuevoServicio,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: _PlaceholderImagen(
                      colorScheme: colorScheme,
                      espaciado: espaciado,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _CampoFormulario(
                    controller: ctrlNombre,
                    etiqueta: 'Nombre *',
                    espaciado: espaciado,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
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
                  _CampoFormulario(
                    controller: ctrlPrecio,
                    etiqueta: 'Precio *',
                    teclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    espaciado: espaciado,
                    validador: _validarPrecio,
                  ),
                  const SizedBox(height: 16),
                  _CampoFormulario(
                    controller: ctrlDuracion,
                    etiqueta: 'Duración (minutos) *',
                    teclado: TextInputType.number,
                    espaciado: espaciado,
                    validador: _validarDuracion,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
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
                  Text(
                    'SKILLS REQUERIDAS',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (vmCatalogo.skills.isEmpty)
                    Text(
                      'Sin skills disponibles',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in vmCatalogo.skills)
                          ChipSkill(
                            etiqueta: skill.nombre,
                            seleccionado: skillsSeleccionadas.contains(
                              skill.id,
                            ),
                            onTap: () => onSkillTap(skill.id),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  String? _validarPrecio(String? valor) {
    final String texto = valor?.trim().replaceAll(',', '.') ?? '';
    final double? precio = double.tryParse(texto);
    if (precio == null || precio <= 0) {
      return 'Introduce un precio válido';
    }
    return null;
  }

  String? _validarDuracion(String? valor) {
    final int? duracion = int.tryParse(valor?.trim() ?? '');
    if (duracion == null || duracion <= 0) {
      return 'Introduce una duración válida';
    }
    return null;
  }
}

class _AvisoError extends StatelessWidget {
  const _AvisoError({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: espaciado.radioCard,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _PlaceholderImagen extends StatelessWidget {
  const _PlaceholderImagen({
    required this.colorScheme,
    required this.espaciado,
  });

  final ColorScheme colorScheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: espaciado.radioCard,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Icon(Icons.image_outlined, color: colorScheme.outline, size: 32),
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  const _CampoFormulario({
    required this.controller,
    required this.etiqueta,
    required this.espaciado,
    this.teclado,
    this.validador,
  });

  final TextEditingController controller;
  final String etiqueta;
  final EspaciadoCitaria espaciado;
  final TextInputType? teclado;
  final String? Function(String?)? validador;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: espaciado.radioInput),
      ),
    );
  }
}
