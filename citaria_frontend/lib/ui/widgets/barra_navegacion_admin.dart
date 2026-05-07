import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/widgets/barra_navegacion_citaria.dart';

/// Secciones principales del área de administración.
enum SeccionAdmin { inicio, reservas, clientes, mas }

/// Barra de navegación inferior del área de administración.
///
/// Recibe la [seccionActiva] para resaltar el tab correspondiente.
/// El tab "Más" no navega a ninguna pantalla: abre el [Drawer] del
/// [Scaffold] padre usando [Scaffold.of(context).openDrawer()].
/// Los demás tabs delegan en [GestorNavegacion].
class BarraNavegacionAdmin extends StatelessWidget {
  const BarraNavegacionAdmin({super.key, required this.seccionActiva});

  final SeccionAdmin seccionActiva;

  int get _indiceActivo {
    switch (seccionActiva) {
      case SeccionAdmin.inicio:
        return 0;
      case SeccionAdmin.reservas:
        return 1;
      case SeccionAdmin.clientes:
        return 2;
      case SeccionAdmin.mas:
        return 3;
    }
  }

  void _manejarTap(BuildContext context, int indice) {
    switch (indice) {
      case 0:
        GestorNavegacion.irAAdminInicio(context);
      case 1:
        GestorNavegacion.irAAdminReservas(context);
      case 2:
        GestorNavegacion.irAAdminClientes(context);
      case 3:
        // El tab "Más" abre el Drawer del Scaffold padre.
        // No navega a ninguna pantalla.
        Scaffold.of(context).openDrawer();
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
          icono: Icons.calendar_today_outlined,
          label: 'Reservas',
        ),
        ItemBarraNavegacionCitaria(
          icono: Icons.people_outline,
          label: 'Clientes',
        ),
        ItemBarraNavegacionCitaria(icono: Icons.menu, label: 'Más'),
      ],
    );
  }
}
