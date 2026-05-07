import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/chip_skill.dart';

// ── Constantes de dominio ─────────────────────────────────────────────────────

const List<String> _categorias = [
  'Exterior', 'Interior', 'Premium', 'Detailing',
];

const List<String> _skillsDisponibles = [
  'Exterior', 'Interior', 'Premium', 'Detallado',
  'Cera', 'Pulido', 'Tapicería', 'Aspirado',
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P32 — Formulario de alta de nuevo servicio.
class PantallaAdminNuevoServicio extends StatefulWidget {
  const PantallaAdminNuevoServicio({super.key});

  @override
  State<PantallaAdminNuevoServicio> createState() =>
      _PantallaAdminNuevoServicioState();
}

class _PantallaAdminNuevoServicioState
    extends State<PantallaAdminNuevoServicio> {
  final _ctrlNombre      = TextEditingController();
  final _ctrlDescripcion = TextEditingController();
  final _ctrlPrecio      = TextEditingController();
  final _ctrlDuracion    = TextEditingController();

  String? _categoriaSeleccionada;
  final Set<String> _skillsSeleccionadas = {};

  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlDescripcion.dispose();
    _ctrlPrecio.dispose();
    _ctrlDuracion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CabeceraPantalla(
        titulo: 'Nuevo servicio',
        mostrarAtras: true,
      ),
      bottomNavigationBar: BarraCtaFija(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: POST /servicios
            },
            child: const Text('Crear servicio'),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 32),
        children: [
          // ── Placeholder imagen ─────────────────────────────────────────────
          Center(
            child: _PlaceholderImagen(
              colorScheme: colorScheme,
              espaciado: espaciado,
            ),
          ),
          const SizedBox(height: 28),

          // ── Formulario ─────────────────────────────────────────────────────
          _CampoTexto(controlador: _ctrlNombre, etiqueta: 'Nombre *'),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrlDescripcion,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: espaciado.radioInput,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CampoTexto(
            controlador: _ctrlPrecio,
            etiqueta: 'Precio *',
            teclado: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _CampoTexto(
            controlador: _ctrlDuracion,
            etiqueta: 'Duración (minutos) *',
            teclado: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownMenu<String>(
            label: const Text('Categoría'),
            expandedInsets: EdgeInsets.zero,
            initialSelection: _categoriaSeleccionada,
            onSelected: (valor) =>
                setState(() => _categoriaSeleccionada = valor),
            dropdownMenuEntries: _categorias
                .map((c) => DropdownMenuEntry<String>(value: c, label: c))
                .toList(),
          ),
          const SizedBox(height: 28),

          // ── Skills requeridas ──────────────────────────────────────────────
          Text(
            'SKILLS REQUERIDAS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in _skillsDisponibles)
                ChipSkill(
                  etiqueta: skill,
                  seleccionado: _skillsSeleccionadas.contains(skill),
                  onTap: () => setState(() {
                    if (_skillsSeleccionadas.contains(skill)) {
                      _skillsSeleccionadas.remove(skill);
                    } else {
                      _skillsSeleccionadas.add(skill);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets privados ───────────────────────────────────────────────────────

class _PlaceholderImagen extends StatelessWidget {
  const _PlaceholderImagen({
    required this.colorScheme,
    required this.espaciado,
  });

  final ColorScheme colorScheme;
  final EspaciadoCitaria espaciado;

  @override
  Widget build(BuildContext context) {
    // TODO: image_picker cuando se implemente
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
      child: Icon(
        Icons.image_outlined,
        color: colorScheme.outline,
        size: 32,
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.controlador,
    required this.etiqueta,
    this.teclado = TextInputType.text,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final TextInputType teclado;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    return TextField(
      controller: controlador,
      keyboardType: teclado,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: OutlineInputBorder(borderRadius: espaciado.radioInput),
      ),
    );
  }
}