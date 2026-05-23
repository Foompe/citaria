import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_categoria.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as estado_ui;
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_catalogo_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_reservas_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';

class PantallaInicioCliente extends StatefulWidget {
  const PantallaInicioCliente({super.key});

  @override
  State<PantallaInicioCliente> createState() => _PantallaInicioClienteState();
}

class _PantallaInicioClienteState extends State<PantallaInicioCliente> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelCatalogoCliente>().cargarCatalogo();
      context.read<ViewModelReservasCliente>().cargarReservasCliente();
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final autenticacion = context.watch<ViewModelAutenticacion>();
    final usuario = autenticacion.usuarioActual;
    final empresa = autenticacion.empresaActiva;
    final tema = context.watch<ViewModelTema>();
    final catalogo = context.watch<ViewModelCatalogoCliente>();
    final reservas = context.watch<ViewModelReservasCliente>();
    final categorias = catalogo.categorias;
    final serviciosDestacados = catalogo.serviciosDestacados;
    final proximaReserva = reservas.proximaReserva;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.inicio,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.chat_bubble_outline,
        tooltip: 'Abrir asistente',
        heroTag: 'fab-chatbot',
        onPressed: () => GestorNavegacion.irAChatbot(context),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  8,
                  espaciado.padX,
                  16,
                ),
                child: Row(
                  children: [
                    AvatarFallbackCitaria(
                      texto: empresa?.nombre ?? 'Empresa',
                      imagenUrl: tema.datos?.logoUrl,
                      tamano: 40,
                      radio: 12,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${usuario?.nombre ?? 'cliente'}',
                      style: textTheme.displayLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¿Qué servicio necesitas hoy?',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
                    itemCount: categorias.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final categoria = categorias[i];
                      return GestureDetector(
                        onTap: () => context
                            .read<ViewModelCatalogoCliente>()
                            .seleccionarCategoria(categoria.id),
                        child: ChipCategoria(
                          etiqueta: categoria.nombre,
                          activo: categoria.activa,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: espaciado.padX,
                  right: espaciado.padX,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Servicios destacados', style: textTheme.displaySmall),
                    GestureDetector(
                      onTap: () => GestorNavegacion.irACatalogo(context),
                      child: Text(
                        'Ver todos',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 160,
                  child: serviciosDestacados.isEmpty
                      ? Center(
                          child: Text(
                            catalogo.cargando
                                ? 'Cargando servicios...'
                                : catalogo.error ??
                                      'No hay servicios disponibles.',
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: espaciado.padX,
                          ),
                          itemCount: serviciosDestacados.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final servicio = serviciosDestacados[i];
                            return _TarjetaServicioDestacado(
                              nombre: servicio.nombre,
                              duracion: servicio.duracionTexto,
                              precio: servicio.precioTexto,
                              imagenUrl: servicio.imagenUrl,
                              onTap: () => GestorNavegacion.irADetalleServicio(
                                context,
                                servicio.id.toString(),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  28,
                  espaciado.padX,
                  0,
                ),
                child: Text(
                  'Próxima cita',
                  style: textTheme.displaySmall,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  espaciado.padX,
                  12,
                  espaciado.padX,
                  32,
                ),
                child: proximaReserva == null
                    ? Text(
                        reservas.cargando
                            ? 'Cargando reservas...'
                            : reservas.error ?? 'No tienes próximas reservas.',
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      )
                    : _TarjetaProximaCita(
                        estado: _estadoUi(proximaReserva.estado),
                        nombreServicio: proximaReserva.nombreServicio,
                        meta: proximaReserva.metaFechaHora,
                        precio: proximaReserva.precioTexto,
                        onTap: () => GestorNavegacion.irADetalleReservaCliente(
                          context,
                          proximaReserva.id.toString(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

estado_ui.EstadoReserva _estadoUi(EstadoReservaPresentacion estado) {
  return switch (estado) {
    EstadoReservaPresentacion.confirmada => estado_ui.EstadoReserva.confirmada,
    EstadoReservaPresentacion.cancelada => estado_ui.EstadoReserva.cancelada,
    EstadoReservaPresentacion.completada => estado_ui.EstadoReserva.completada,
    EstadoReservaPresentacion.pendiente => estado_ui.EstadoReserva.pendiente,
  };
}

class _TarjetaServicioDestacado extends StatelessWidget {
  const _TarjetaServicioDestacado({
    required this.nombre,
    required this.duracion,
    required this.precio,
    required this.imagenUrl,
    required this.onTap,
  });

  final String nombre;
  final String duracion;
  final String precio;
  final String? imagenUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: espaciado.radioCard,
        child: SizedBox(
          width: 200,
          child: _FondoServicioDestacado(
            imagenUrl: imagenUrl,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    nombre,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          duracion,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.86,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        precio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FondoServicioDestacado extends StatelessWidget {
  const _FondoServicioDestacado({required this.imagenUrl, required this.child});

  final String? imagenUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String? url = imagenUrl?.trim();

    if (url == null || url.isEmpty) {
      return _fondoAzul(colorScheme, child);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fondoAzul(colorScheme, const SizedBox()),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB3000000)],
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _fondoAzul(ColorScheme colorScheme, Widget contenido) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.primary.withValues(alpha: 0.50),
          ],
        ),
      ),
      child: contenido,
    );
  }
}

class _TarjetaProximaCita extends StatelessWidget {
  const _TarjetaProximaCita({
    required this.estado,
    required this.nombreServicio,
    required this.meta,
    required this.precio,
    required this.onTap,
  });

  final estado_ui.EstadoReserva estado;
  final String nombreServicio;
  final String meta;
  final String precio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: espaciado.radioCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  estado_ui.ChipEstado(estado: estado),
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              const SizedBox(height: 10),
              Text(nombreServicio, style: textTheme.displaySmall),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(meta, style: textTheme.bodySmall),
                  Text(
                    precio,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
