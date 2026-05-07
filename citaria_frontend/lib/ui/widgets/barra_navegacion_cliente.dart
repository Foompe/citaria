import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_citaria.dart';

/// Secciones principales del área cliente.
enum SeccionCliente { inicio, catalogo, reservas, perfil }

/// Barra de navegación inferior del área cliente.
///
/// Recibe la [seccionActiva] para resaltar el tab correspondiente
/// y delega toda navegación en [GestorNavegacion].
class BarraNavegacionCliente extends StatelessWidget {
  const BarraNavegacionCliente({super.key, required this.seccionActiva});

  final SeccionCliente seccionActiva;

  int get _indiceActivo {
    switch (seccionActiva) {
      case SeccionCliente.inicio:
        return 0;
      case SeccionCliente.catalogo:
        return 1;
      case SeccionCliente.reservas:
        return 2;
      case SeccionCliente.perfil:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BarraNavegacionCitaria(
      indiceActivo: _indiceActivo,
      onTap: (indice) => _manejarTap(context, indice),
      items: const [
        ItemBarraNavegacionCitaria(icono: Icons.home_outlined, label: 'Inicio'),
        ItemBarraNavegacionCitaria(
          icono: Icons.grid_view_outlined,
          label: 'Servicios',
        ),
        ItemBarraNavegacionCitaria(
          icono: Icons.calendar_month_outlined,
          label: 'Reservas',
        ),
        ItemBarraNavegacionCitaria(
          icono: Icons.person_outline,
          label: 'Perfil',
        ),
      ],
    );
  }

  void _manejarTap(BuildContext context, int indice) {
    switch (indice) {
      case 0:
        GestorNavegacion.irAInicioCliente(context);
      case 1:
        GestorNavegacion.irACatalogo(context);
      case 2:
        GestorNavegacion.irAMisReservas(context);
      case 3:
        GestorNavegacion.irAPerfil(context);
    }
  }
}
