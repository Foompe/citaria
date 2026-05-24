import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
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
  final Set<int> _skillsSeleccionadas = <int>{};
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
    _skillsSeleccionadas
      ..clear()
      ..addAll(detalle.skillIds);
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
      skillIds: _skillsSeleccionadas,
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

  void _alternarSkill(int id) {
    setState(() {
      if (_skillsSeleccionadas.contains(id)) {
        _skillsSeleccionadas.remove(id);
      } else {
        _skillsSeleccionadas.add(id);
      }
    });
  }

  void _mostrarImagenNoImplementada() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función no implementada.')),
    );
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
                  const CabeceraTituloGrande(
                    titulo: 'Servicio',
                    mostrarAtras: true,
                  ),
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
              skills: vmCatalogo.skills,
              categoriaSeleccionadaId: _categoriaSeleccionadaId,
              skillsSeleccionadas: _skillsSeleccionadas,
              activo: _activo,
              onCategoriaChanged: (id) =>
                  setState(() => _categoriaSeleccionadaId = id),
              onSkillTap: _alternarSkill,
              onActivoChanged: (valor) => setState(() => _activo = valor),
              onHorasChanged: (h) => setState(() => _duracionHoras = h),
              onMinutosChanged: (m) => setState(() => _duracionMinutos = m),
              onReintentar: () => vmCatalogo.cargarDetalleServicio(widget.id),
              onDesactivar: detalle == null ? null : _desactivar,
              onEditarImagen: _mostrarImagenNoImplementada,
            ),
                ),
              ),
          );
        },
      ),
    );
  }
}

// ── Cuerpo ────────────────────────────────────────────────────────────────────

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
    required this.skills,
    required this.categoriaSeleccionadaId,
    required this.skillsSeleccionadas,
    required this.activo,
    required this.onCategoriaChanged,
    required this.onSkillTap,
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
  final List<DtoSkillCatalogoAdmin> skills;
  final int? categoriaSeleccionadaId;
  final Set<int> skillsSeleccionadas;
  final bool activo;
  final ValueChanged<int?> onCategoriaChanged;
  final ValueChanged<int> onSkillTap;
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
          // ── Imagen ────────────────────────────────────────────────────────
          Center(
            child: _ImagenServicioEditable(
              imagenUrl: detalle!.imagenUrl,
              espaciado: espaciado,
              colorScheme: colorScheme,
              onEditar: onEditarImagen,
            ),
          ),
          const SizedBox(height: 24),

          // ── Campos de texto ───────────────────────────────────────────────
          TextFormField(
            controller: ctrlNombre,
            validator: (valor) =>
                valor == null || valor.trim().isEmpty
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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: _validarPrecio,
            decoration: InputDecoration(
              labelText: 'Precio *',
              border: OutlineInputBorder(borderRadius: espaciado.radioInput),
            ),
          ),
          const SizedBox(height: 16),

          // ── Duración ──────────────────────────────────────────────────────
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

          // ── Categoría + activo ────────────────────────────────────────────
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

          // ── Skills ────────────────────────────────────────────────────────
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
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
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

          // ── Desactivar ────────────────────────────────────────────────────
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
    if (precio == null || precio <= 0) return 'Introduce un precio válido';
    return null;
  }
}

// ── Imagen editable ───────────────────────────────────────────────────────────

class _ImagenServicioEditable extends StatelessWidget {
  const _ImagenServicioEditable({
    required this.imagenUrl,
    required this.espaciado,
    required this.colorScheme,
    required this.onEditar,
  });

  final String? imagenUrl;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: espaciado.radioCard,
          child: SizedBox(
            width: 120,
            height: 120,
            child: imagenUrl != null && imagenUrl!.isNotEmpty
                ? Image.network(
                    imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _FondoIconoServicio(colorScheme: colorScheme),
                  )
                : _FondoIconoServicio(colorScheme: colorScheme),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onEditar,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomRight: Radius.circular(espaciado.radioCard.topRight.x),
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FondoIconoServicio extends StatelessWidget {
  const _FondoIconoServicio({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.design_services_outlined,
          size: 48,
          color: colorScheme.outline,
        ),
      ),
    );
  }
}
