import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_admin.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/menu_lateral_admin.dart';

// ── Datos hardcodeados (mismos que PantallaAdminSeleccionCliente) ─────────────
// TODO: datos reales de API

class _DatosCliente {
  const _DatosCliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  final String id;
  final String nombre;
  final String email;
  final String telefono;
}

const List<_DatosCliente> _clientesEjemplo = [
  _DatosCliente(
    id: 'c1',
    nombre: 'Ana García',
    email: 'ana.garcia@email.com',
    telefono: '+34 612 345 678',
  ),
  _DatosCliente(
    id: 'c2',
    nombre: 'Luis Martín',
    email: 'luis.martin@email.com',
    telefono: '+34 623 456 789',
  ),
  _DatosCliente(
    id: 'c3',
    nombre: 'Marta López',
    email: 'marta.lopez@email.com',
    telefono: '+34 634 567 890',
  ),
  _DatosCliente(
    id: 'c4',
    nombre: 'Pedro Ruiz',
    email: 'pedro.ruiz@email.com',
    telefono: '+34 645 678 901',
  ),
  _DatosCliente(
    id: 'c5',
    nombre: 'Sara Gómez',
    email: 'sara.gomez@email.com',
    telefono: '+34 656 789 012',
  ),
];

// ── Pantalla ──────────────────────────────────────────────────────────────────

/// P23 — Listado de clientes del área admin.
///
/// Pantalla independiente con [drawer] y [BottomNavigationBar] admin.
/// Reutiliza la misma UI que [PantallaAdminSeleccionCliente] pero
/// en modo exploración (modoSeleccion: false).
///
/// Decisión técnica: no se instancia [PantallaAdminSeleccionCliente]
/// dentro de esta pantalla para evitar doble [Scaffold] anidado.
class PantallaAdminClientes extends StatefulWidget {
  const PantallaAdminClientes({super.key});

  @override
  State<PantallaAdminClientes> createState() => _PantallaAdminClientesState();
}

class _PantallaAdminClientesState extends State<PantallaAdminClientes> {
  final TextEditingController _busqueda = TextEditingController();
  String _textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() {
      setState(() => _textoBusqueda = _busqueda.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<_DatosCliente> get _clientesFiltrados {
    if (_textoBusqueda.isEmpty) return _clientesEjemplo;
    return _clientesEjemplo
        .where((c) =>
            c.nombre.toLowerCase().contains(_textoBusqueda) ||
            c.email.toLowerCase().contains(_textoBusqueda) ||
            c.telefono.contains(_textoBusqueda))
        .toList();
  }

  String _iniciales(String nombre) {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const MenuLateralAdmin(),
      bottomNavigationBar: const BarraNavegacionAdmin(
        seccionActiva: SeccionAdmin.clientes,
      ),
      appBar: CabeceraPantalla(
        titulo: 'Clientes',
        mostrarAtras: false,
        accionDerecha: Tooltip(
          message: 'Nuevo cliente',
          child: IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => GestorNavegacion.irAAdminNuevoCliente(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Buscador ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              espaciado.padX,
              16,
              espaciado.padX,
              8,
            ),
            child: TextField(
              controller: _busqueda,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar cliente…',
                border: OutlineInputBorder(
                  borderRadius: espaciado.radioInput,
                ),
              ),
            ),
          ),

          // ── Lista de clientes ─────────────────────────────────────────────
          Expanded(
            child: _clientesFiltrados.isEmpty
                ? Center(
                    child: Text(
                      'Sin resultados',
                      style: textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientesFiltrados[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            _iniciales(cliente.nombre),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(cliente.nombre),
                        subtitle: Text(
                          cliente.email,
                          style: textTheme.bodySmall,
                        ),
                        onTap: () => GestorNavegacion.irAAdminDetalleCliente(
                          context,
                          cliente.id,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}