import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_horarios.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PantallaAdminNuevoCierre extends StatefulWidget {
  const PantallaAdminNuevoCierre({super.key});

  @override
  State<PantallaAdminNuevoCierre> createState() =>
      _PantallaAdminNuevoCierreState();
}

class _PantallaAdminNuevoCierreState extends State<PantallaAdminNuevoCierre> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlFecha = TextEditingController();
  final _ctrlMotivo = TextEditingController();
  final _formatoFecha = DateFormat('d MMM yyyy', 'es_ES');
  late final ViewModelAdminHorarios _viewModel;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewModelAdminHorarios(
      repoOrganizaciones: context.read<RepoOrganizaciones>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void dispose() {
    _ctrlFecha.dispose();
    _ctrlMotivo.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime hoy = DateTime.now();
    final DateTime fechaInicial = _fechaSeleccionada ?? hoy;
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 5),
    );

    if (fecha == null) {
      return;
    }

    setState(() {
      _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
      _ctrlFecha.text = _formatoFecha.format(_fechaSeleccionada!);
    });
  }

  Future<void> _crearCierre() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final DateTime? fecha = _fechaSeleccionada;
    if (fecha == null) return;

    final int? cantidad = await _viewModel.consultarCitasEnFecha(fecha);
    if (!mounted) return;

    if (cantidad != null && cantidad > 0) {
      final bool? confirmado = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Citas activas ese día'),
          content: Text(
            'Ese día hay $cantidad ${cantidad == 1 ? 'cita activa' : 'citas activas'}. '
            'Al crear el cierre se cancelarán todas automáticamente. ¿Continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (confirmado != true) return;
    }

    if (!mounted) return;

    final cierre = await _viewModel.crearCierre(
      fecha: fecha,
      motivo: _ctrlMotivo.text,
    );

    if (!mounted) return;

    if (cierre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'No se pudo crear el cierre.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cierre creado')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;

    return ChangeNotifierProvider<ViewModelAdminHorarios>.value(
      value: _viewModel,
      child: Consumer<ViewModelAdminHorarios>(
        builder: (context, vmHorarios, _) => Scaffold(
          bottomNavigationBar: BarraCtaFija(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vmHorarios.cargando ? null : _crearCierre,
                child: vmHorarios.cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cierre'),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                const CabeceraTituloGrande(titulo: 'Nuevo cierre'),
              ],
              body: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    espaciado.padX,
                    24,
                    espaciado.padX,
                    120,
                  ),
                  children: [
                    TextFormField(
                      controller: _ctrlFecha,
                      readOnly: true,
                      onTap: _seleccionarFecha,
                      validator: (_) => _fechaSeleccionada == null
                          ? 'La fecha es obligatoria'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Fecha *',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: espaciado.radioInput,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ctrlMotivo,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Motivo',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: espaciado.radioInput,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
