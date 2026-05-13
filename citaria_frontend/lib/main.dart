import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/rutas.dart';
import 'package:citaria_frontend/ui/theme/tema_citaria.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_detalle_servicio.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_detalle_reserva_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_reserva.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_empleado.dart';


void main() {
  runApp(const AplicacionCitaria());
}

/// Widget raíz de la aplicación Citaria.
/// 
/// Registra los ViewModels globales y configura tema y enrutamiento.
class AplicacionCitaria extends StatelessWidget {
  const AplicacionCitaria({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ViewModelAutenticacion>(
          create: (_) => ViewModelAutenticacion(),
        ),
      ],
      child: MaterialApp(
        title: 'Citaria',
        debugShowCheckedModeBanner: false,
        // Un único tema claro. Sin darkTheme ni themeMode.
        theme: temaCitaria,
        initialRoute: Rutas.splash,
        // initialRoute: Rutas.adminInicio,
        routes: Rutas.mapaDeRutas(),
        onGenerateRoute: (settings) {
          if (settings.name != null &&
              settings.name!.startsWith('/servicio/')) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PantallaDetalleServicio(),
            );
          }
          if (settings.name != null && settings.name!.startsWith('/reserva/')) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PantallaDetalleReservaCliente(),
            );
          }
          if (settings.name != null &&
              settings.name!.startsWith('/admin/reservas/')) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PantallaAdminDetalleReserva(),
            );
          }
          if (settings.name != null &&
              settings.name!.startsWith('/admin/clientes/') &&
              !settings.name!.endsWith('/nuevo')) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PantallaAdminDetalleCliente(),
            );
          }
          if (settings.name != null &&
              settings.name!.startsWith('/admin/empleados/') &&
              !settings.name!.endsWith('/nuevo')) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PantallaAdminDetalleEmpleado(),
            );
          }
          return null;
        },
      ),
    );
  }
}
