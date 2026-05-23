import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
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
  final _ctrlDuracion = TextEditingController();
  final Set<int> _skillsSeleccionadas = <int>{};
  late final ViewModelAdminCatalogo _viewModel;
  int? _categoriaSeleccionadaId;
  bool _activo = true;
  bool _sincronizado = false;

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
    _ctrlDuracion.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final servicio = await _viewModel.actualizarServicio(
      id: widget.id,
      nombre: _ctrlNombre.text,
      descripcion: _ctrlDescripcion.text,
      precio: _ctrlPrecio.text,
      duracion: _ctrlDuracion.text,
      categoriaId: _categoriaSeleccionadaId,
      activo: _activo,
      skillIds: _skillsSeleccionadas,
    );

    if (!mounted) {
      return;
    }

    if (servicio == null) {
      _mostrarError('No se pudo guardar el servicio.');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Servicio guardado')));
    Navigator.pop(context, true);
  }

  Future<void> _desactivar() async {
    final bool ok = await _viewModel.desactivarServicio(widget.id);
    if (!mounted) {
      return;
    }
    if (!ok) {
      _mostrarError('No se pudo desactivar el servicio.');
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Servicio desactivado')));
    Navigator.pop(context, true);
  }

  void _mostrarError(String fallback) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.error ?? fallback)));
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

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return ChangeNotifierProvider<ViewModelAdminCatalogo>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminCatalogo>(
        builder: (context, vmCatalogo, _) {
          final detalle = vmCatalogo.detalleServicio;
          if (detalle != null && !_sincronizado) {
            _ctrlNombre.text = detalle.nombre;
            _ctrlDescripcion.text = detalle.descripcion;
            _ctrlPrecio.text = detalle.precio.toStringAsFixed(2);
            _ctrlDuracion.text = detalle.duracionMinutos.toString();
            _categoriaSeleccionadaId = detalle.categoriaId;
            _activo = detalle.activo;
            _skillsSeleccionadas
              ..clear()
              ..addAll(detalle.skillIds);
            _sincronizado = true;
          }

          return Scaffold(
            appBar: const CabeceraPantalla(
              titulo: 'Servicio',
              mostrarAtras: true,
            ),
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
            body: _CuerpoDetalleServicio(
              detalle: detalle,
              cargando: vmCatalogo.cargando,
              error: vmCatalogo.error,
              espaciado: espaciado,
              formKey: _formKey,
              ctrlNombre: _ctrlNombre,
              ctrlDescripcion: _ctrlDescripcion,
              ctrlPrecio: _ctrlPrecio,
              ctrlDuracion: _ctrlDuracion,
              categorias: vmCatalogo.categorias,
              skills: vmCatalogo.skills,
              categoriaSeleccionadaId: _categoriaSeleccionadaId,
              skillsSeleccionadas: _skillsSeleccionadas,
              activo: _activo,
              onCategoriaChanged: (id) =>
                  setState(() => _categoriaSeleccionadaId = id),
              onSkillTap: _alternarSkill,
              onActivoChanged: (valor) => setState(() => _activo = valor),
              onReintentar: () => vmCatalogo.cargarDetalleServicio(widget.id),
              onDesactivar: detalle == null ? null : _desactivar,
            ),
          );
        },
      ),
    );
  }
}

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
    required this.ctrlDuracion,
    required this.categorias,
    required this.skills,
    required this.categoriaSeleccionadaId,
    required this.skillsSeleccionadas,
    required this.activo,
    required this.onCategoriaChanged,
    required this.onSkillTap,
    required this.onActivoChanged,
    required this.onReintentar,
    required this.onDesactivar,
  });

  final DtoDetalleServicioCatalogoAdmin? detalle;
  final bool cargando;
  final String? error;
  final EspaciadoCitaria espaciado;
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrlNombre;
  final TextEditingController ctrlDescripcion;
  final TextEditingController ctrlPrecio;
  final TextEditingController ctrlDuracion;
  final List<DtoCategoriaCatalogoAdmin> categorias;
  final List<DtoSkillCatalogoAdmin> skills;
  final int? categoriaSeleccionadaId;
  final Set<int> skillsSeleccionadas;
  final bool activo;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<int> onSkillTap;
  final ValueChanged<bool> onActivoChanged;
  final VoidCallback onReintentar;
  final VoidCallback? onDesactivar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && detalle == null) {
      return _EstadoCentrado(
        mensaje: error!,
        accionTexto: 'Reintentar',
        onAccion: onReintentar,
      );
    }
    if (detalle == null) {
      return _EstadoCentrado(
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
          TextFormField(
            controller: ctrlNombre,
            validator: (valor) => valor == null || valor.trim().isEmpty
                ? 'El nombre es obligatorio'
                : null,
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validarPrecio,
            decoration: InputDecoration(
              labelText: 'Precio *',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: ctrlDuracion,
            keyboardType: TextInputType.number,
            validator: _validarDuracion,
            decoration: InputDecoration(
              labelText: 'Duración (minutos) *',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
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
          const SizedBox(height: 24),
          Text(
            'SKILLS REQUERIDAS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          if (skills.isEmpty)
            Text(
              'Sin skills disponibles',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in skills)
                  ChipSkill(
                    etiqueta: skill.nombre,
                    seleccionado: skillsSeleccionadas.contains(skill.id),
                    onTap: () => onSkillTap(skill.id),
                  ),
              ],
            ),
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
