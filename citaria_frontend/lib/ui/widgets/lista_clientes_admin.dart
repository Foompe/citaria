import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListaClientesAdmin extends StatefulWidget {
  const ListaClientesAdmin({
    super.key,
    required this.modoSeleccion,
    required this.onTap,
  });

  final bool modoSeleccion;
  final void Function(DtoClienteAdmin) onTap;

  @override
  State<ListaClientesAdmin> createState() => _ListaClientesAdminState();
}

class _ListaClientesAdminState extends State<ListaClientesAdmin> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vm = context.read<ViewModelAdminClientes>();
    if (vm.cargando || !vm.hayMasPaginas) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      vm.cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmClientes = context.watch<ViewModelAdminClientes>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final List<DtoClienteAdmin> clientes = vmClientes.clientes;
    final String? error = vmClientes.error;

    if (vmClientes.cargando && clientes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && clientes.isEmpty) {
      return EstadoClientesAdmin(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: vmClientes.refrescar,
      );
    }

    if (clientes.isEmpty) {
      return const EstadoClientesAdmin(mensaje: 'Sin resultados');
    }

    final bool mostrarLoader = vmClientes.hayMasPaginas;
    final int itemCount = clientes.length + (mostrarLoader ? 1 : 0);

    return RefreshIndicator(
      onRefresh: vmClientes.refrescar,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == clientes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final DtoClienteAdmin cliente = clientes[index];
          return ListTile(
            leading: AvatarFallbackCitaria(
              texto: cliente.nombreCompleto,
              imagenUrl: cliente.fotoUrl,
              tamano: 44,
              radio: 22,
            ),
            title: Text(cliente.nombreCompleto),
            subtitle: Text(
              widget.modoSeleccion ? cliente.telefono : cliente.email,
              style: textTheme.bodySmall,
            ),
            trailing: cliente.tieneUsuario
                ? Icon(Icons.verified, color: colorScheme.primary, size: 20)
                : null,
            onTap: () => widget.onTap(cliente),
          );
        },
      ),
    );
  }
}

class EstadoClientesAdmin extends StatelessWidget {
  const EstadoClientesAdmin({
    super.key,
    required this.mensaje,
    this.accionTexto,
    this.onAccion,
  });

  final String mensaje;
  final String? accionTexto;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (accionTexto != null && onAccion != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAccion, child: Text(accionTexto!)),
            ],
          ],
        ),
      ),
    );
  }
}
