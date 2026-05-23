import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_cta_fija.dart';
import 'package:citaria_frontend/ui/widgets/etiqueta_wizard.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_catalogo_cliente.dart';

class PantallaDetalleServicio extends StatefulWidget {
  const PantallaDetalleServicio({super.key, this.modoAdmin = false});

  final bool modoAdmin;

  @override
  State<PantallaDetalleServicio> createState() =>
      _PantallaDetalleServicioState();
}

class _PantallaDetalleServicioState extends State<PantallaDetalleServicio> {
  bool _iniciado = false;
  int? _id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, Object?>) {
      final Object? idArg = args['id'];
      _id = int.tryParse(idArg?.toString() ?? '');
    }
    final int? id = _id;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ViewModelCatalogoCliente>().cargarDetalleServicio(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final catalogo = context.watch<ViewModelCatalogoCliente>();
    final servicio = catalogo.detalle;

    return Scaffold(
      body: servicio == null
          ? Center(
              child: Text(
                catalogo.cargando
                    ? 'Cargando servicio...'
                    : catalogo.error ?? 'No se ha podido cargar el servicio.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: screenHeight * 0.40,
                  pinned: true,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      child: const BackButton(color: Colors.white),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _CabeceraServicio(
                      imagenUrl: servicio.imagenUrl,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            espaciado.radioCard.topLeft.x * 2,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        espaciado.padX,
                        24,
                        espaciado.padX,
                        120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: espaciado.radioPill,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          EtiquetaWizard(etiqueta: servicio.categoria),
                          const SizedBox(height: 10),
                          Text(servicio.nombre, style: textTheme.displayLarge),
                          const SizedBox(height: 10),
                          Text(
                            servicio.descripcion,
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          _FilaDetalle(
                            icono: Icons.access_time,
                            label: 'Duración',
                            valor: servicio.duracionTexto,
                          ),
                          const SizedBox(height: 12),
                          _FilaDetalle(
                            icono: Icons.euro,
                            label: 'Precio',
                            valor: servicio.precioTexto,
                            estiloValor: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          if (widget.modoAdmin &&
                              servicio.skills.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Skills requeridas',
                              style: textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: servicio.skills
                                  .map(
                                    (skill) => EtiquetaWizard(etiqueta: skill),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: servicio == null
          ? null
          : BarraCtaFija(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => GestorNavegacion.irAWizardServicios(
                    context,
                    servicioPreseleccionado: servicio.id.toString(),
                  ),
                  child: const Text('Reservar este servicio'),
                ),
              ),
            ),
    );
  }
}

class _CabeceraServicio extends StatelessWidget {
  const _CabeceraServicio({required this.imagenUrl});

  final String? imagenUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String? url = imagenUrl?.trim();
    if (url == null || url.isEmpty) {
      return _fondoAzul(colorScheme);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fondoAzul(colorScheme),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x99000000)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fondoAzul(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  const _FilaDetalle({
    required this.icono,
    required this.label,
    required this.valor,
    this.estiloValor,
  });

  final IconData icono;
  final String label;
  final String valor;
  final TextStyle? estiloValor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icono, size: 18, color: colorScheme.outline),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: textTheme.bodyLarge)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valor,
            style: estiloValor ?? textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
