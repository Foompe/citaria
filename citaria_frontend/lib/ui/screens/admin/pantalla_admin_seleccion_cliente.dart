import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';

// ── Datos hardcodeados ────────────────────────────────────────────────────────
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

/// P22 — Selección de cliente para nueva reserva.
///
/// Ruta: /admin/nueva-reserva/cliente
/// Argument opcional 'modoSeleccion' (bool) — por defecto true.
///   true  → seleccionar cliente para nueva reserva
///   false → modo exploración (PantallaAdminClientes lo instancia así)
class PantallaAdminSeleccionCliente extends StatefulWidget {
  const PantallaAdminSeleccionCliente({super.key});

  @override
  State<PantallaAdminSeleccionCliente> createState() =>
      _PantallaAdminSeleccionClienteState();
}

class _PantallaAdminSeleccionClienteState
    extends State<PantallaAdminSeleccionCliente> {
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

  bool _esModoSeleccion(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['modoSeleccion'] as bool? ?? true;
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
    final modoSeleccion  = _esModoSeleccion(context);
    final espaciado      = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme    = Theme.of(context).colorScheme;
    final textTheme      = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CabeceraPantalla(
        titulo: modoSeleccion ? 'Seleccionar cliente' : 'Clientes',
        mostrarAtras: true,
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
          // ── Buscador ───────────────────────────────────────────────────────
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

          // ── Lista de clientes ──────────────────────────────────────────────
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
                          modoSeleccion ? cliente.telefono : cliente.email,
                          style: textTheme.bodySmall,
                        ),
                        onTap: () {
                          if (modoSeleccion) {
                            GestorNavegacion.irAWizardServicios(context);
                          } else {
                            GestorNavegacion.irAAdminDetalleCliente(
                              context,
                              cliente.id,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}