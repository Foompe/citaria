import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_cliente.dart';
import 'package:citaria_frontend/ui/widgets/chip_categoria.dart';
import 'package:citaria_frontend/ui/widgets/fab_citaria.dart';
import 'package:citaria_frontend/ui/widgets/fila_servicio.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_catalogo_cliente.dart';

class PantallaCatalogoCliente extends StatefulWidget {
  const PantallaCatalogoCliente({super.key});

  @override
  State<PantallaCatalogoCliente> createState() =>
      _PantallaCatalogoClienteState();
}

class _PantallaCatalogoClienteState extends State<PantallaCatalogoCliente> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelCatalogoCliente>().cargarCatalogo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final catalogo = context.watch<ViewModelCatalogoCliente>();
    final categorias = catalogo.categorias;
    final servicios = catalogo.servicios;

    return Scaffold(
      bottomNavigationBar: const BarraNavegacionCliente(
        seccionActiva: SeccionCliente.catalogo,
      ),
      floatingActionButton: FabCitaria(
        icono: Icons.chat_bubble_outline,
        tooltip: 'Abrir asistente',
        heroTag: 'fab-chatbot',
        onPressed: () => GestorNavegacion.irAChatbot(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                espaciado.padX,
                16,
                espaciado.padX,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicios', style: textTheme.displayLarge),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (valor) =>
                        context.read<ViewModelCatalogoCliente>().buscar(valor),
                    decoration: InputDecoration(
                      hintText: 'Buscar servicio…',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
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
            const SizedBox(height: 8),
            Expanded(
              child: servicios.isEmpty
                  ? Center(
                      child: Text(
                        catalogo.cargando
                            ? 'Cargando servicios...'
                            : catalogo.error ?? 'No hay servicios disponibles.',
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: espaciado.safeBottom),
                      itemCount: servicios.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: espaciado.padX,
                        endIndent: espaciado.padX,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, i) {
                        final servicio = servicios[i];
                        return FilaServicio(
                          nombre: servicio.nombre,
                          descripcion: servicio.descripcion,
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
          ],
        ),
      ),
    );
  }
}
