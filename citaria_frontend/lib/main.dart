import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/repositories/repo_auth.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_chatbot.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_disponibilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/rutas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_catalogo_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_chatbot.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_perfil_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_reservas_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_detalle_servicio.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_detalle_reserva_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_reserva.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_empleado.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  final SharedPreferences preferencias = await SharedPreferences.getInstance();
  final http.Client clienteHttp = http.Client();
  final CitariaApi api = CitariaApi(clienteHttp);
  const FlutterSecureStorage almacenamientoSeguro = FlutterSecureStorage();

  runApp(
    AplicacionCitaria(
      repoAuth: RepoAuth(api),
      repoCatalogo: RepoCatalogo(api),
      repoReservas: RepoReservas(api),
      repoDisponibilidad: RepoDisponibilidad(api),
      repoChatbot: RepoChatbot(api),
      repoOrganizaciones: RepoOrganizaciones(api),
      repoClientes: RepoClientes(api),
      repoEmpleados: RepoEmpleados(api),
      almacenamientoSeguro: almacenamientoSeguro,
      preferencias: preferencias,
    ),
  );
}

/// Widget raíz de la aplicación Citaria.
///
/// Registra los ViewModels globales y configura tema y enrutamiento.
class AplicacionCitaria extends StatelessWidget {
  const AplicacionCitaria({
    super.key,
    required this.repoAuth,
    required this.repoCatalogo,
    required this.repoReservas,
    required this.repoDisponibilidad,
    required this.repoChatbot,
    required this.repoOrganizaciones,
    required this.repoClientes,
    required this.repoEmpleados,
    required this.almacenamientoSeguro,
    required this.preferencias,
  });

  final RepoAuth repoAuth;
  final RepoCatalogo repoCatalogo;
  final RepoReservas repoReservas;
  final RepoDisponibilidad repoDisponibilidad;
  final RepoChatbot repoChatbot;
  final RepoOrganizaciones repoOrganizaciones;
  final RepoClientes repoClientes;
  final RepoEmpleados repoEmpleados;
  final FlutterSecureStorage almacenamientoSeguro;
  final SharedPreferences preferencias;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RepoCatalogo>.value(value: repoCatalogo),
        Provider<RepoReservas>.value(value: repoReservas),
        Provider<RepoDisponibilidad>.value(value: repoDisponibilidad),
        Provider<RepoChatbot>.value(value: repoChatbot),
        ChangeNotifierProvider<ViewModelTema>(
          create: (_) => ViewModelTema(
            repoOrganizaciones: repoOrganizaciones,
            preferencias: preferencias,
          ),
        ),
        ChangeNotifierProvider<ViewModelAutenticacion>(
          create: (_) => ViewModelAutenticacion(
            repoAuth: repoAuth,
            repoOrganizaciones: repoOrganizaciones,
            repoClientes: repoClientes,
            repoEmpleados: repoEmpleados,
            almacenamientoSeguro: almacenamientoSeguro,
            preferencias: preferencias,
          ),
        ),
        ChangeNotifierProvider<ViewModelCatalogoCliente>(
          create: (context) => ViewModelCatalogoCliente(
            repoCatalogo: repoCatalogo,
            autenticacion: context.read<ViewModelAutenticacion>(),
          ),
        ),
        ChangeNotifierProvider<ViewModelReservasCliente>(
          create: (context) => ViewModelReservasCliente(
            repoReservas: repoReservas,
            autenticacion: context.read<ViewModelAutenticacion>(),
          ),
        ),
        ChangeNotifierProvider<ViewModelPerfilCliente>(
          create: (context) => ViewModelPerfilCliente(
            autenticacion: context.read<ViewModelAutenticacion>(),
          ),
        ),
        ChangeNotifierProvider<ViewModelChatbot>(
          create: (context) => ViewModelChatbot(
            repoChatbot: repoChatbot,
            autenticacion: context.read<ViewModelAutenticacion>(),
          ),
        ),
      ],
      child: Consumer<ViewModelTema>(
        builder: (context, tema, _) => MaterialApp(
          title: 'Citaria',
          debugShowCheckedModeBanner: false,
          theme: tema.themeData,
          initialRoute: Rutas.splash,
          routes: Rutas.mapaDeRutas(),
          onGenerateRoute: (settings) {
            final String? nombreRuta = settings.name;
            if (nombreRuta == null) {
              return null;
            }
            if (nombreRuta.startsWith('/servicio/')) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const PantallaDetalleServicio(),
              );
            }
            if (nombreRuta.startsWith('/reserva/')) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const PantallaDetalleReservaCliente(),
              );
            }
            if (nombreRuta.startsWith('/admin/reservas/')) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const PantallaAdminDetalleReserva(),
              );
            }
            if (nombreRuta.startsWith('/admin/clientes/') &&
                !nombreRuta.endsWith('/nuevo')) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const PantallaAdminDetalleCliente(),
              );
            }
            if (nombreRuta.startsWith('/admin/empleados/') &&
                !nombreRuta.endsWith('/nuevo')) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const PantallaAdminDetalleEmpleado(),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
