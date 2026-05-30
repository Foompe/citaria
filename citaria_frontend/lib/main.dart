import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citaria_frontend/data/api/citaria_api.dart';
import 'package:citaria_frontend/data/services/servicio_pin.dart';
import 'package:citaria_frontend/data/repositories/repo_auth.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_chatbot.dart';
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/data/repositories/repo_disponibilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_estadisticas.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/data/repositories/repo_usuarios.dart';
import 'package:citaria_frontend/ui/navigation/rutas.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_catalogo_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_chatbot.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_perfil_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_reservas_cliente.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  final SharedPreferences preferencias = await SharedPreferences.getInstance();
  final http.Client clienteHttp = http.Client();
  final CitariaApi api = CitariaApi(clienteHttp);
  const FlutterSecureStorage almacenamientoSeguro = FlutterSecureStorage();

  final ServicioPin servicioPin = ServicioPin(
    almacenamiento: almacenamientoSeguro,
  );
  await servicioPin.inicializar();

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
      repoEstadisticas: RepoEstadisticas(api),
      repoUsuarios: RepoUsuarios(api),
      almacenamientoSeguro: almacenamientoSeguro,
      preferencias: preferencias,
      servicioPin: servicioPin,
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
    required this.repoEstadisticas,
    required this.repoUsuarios,
    required this.almacenamientoSeguro,
    required this.preferencias,
    required this.servicioPin,
  });

  final RepoAuth repoAuth;
  final RepoCatalogo repoCatalogo;
  final RepoReservas repoReservas;
  final RepoDisponibilidad repoDisponibilidad;
  final RepoChatbot repoChatbot;
  final RepoOrganizaciones repoOrganizaciones;
  final RepoClientes repoClientes;
  final RepoEmpleados repoEmpleados;
  final RepoEstadisticas repoEstadisticas;
  final RepoUsuarios repoUsuarios;
  final FlutterSecureStorage almacenamientoSeguro;
  final SharedPreferences preferencias;
  final ServicioPin servicioPin;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ServicioPin>.value(value: servicioPin),
        Provider<RepoCatalogo>.value(value: repoCatalogo),
        Provider<RepoReservas>.value(value: repoReservas),
        Provider<RepoDisponibilidad>.value(value: repoDisponibilidad),
        Provider<RepoChatbot>.value(value: repoChatbot),
        Provider<RepoOrganizaciones>.value(value: repoOrganizaciones),
        Provider<RepoClientes>.value(value: repoClientes),
        Provider<RepoEmpleados>.value(value: repoEmpleados),
        Provider<RepoEstadisticas>.value(value: repoEstadisticas),
        Provider<RepoUsuarios>.value(value: repoUsuarios),
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
            repoClientes: repoClientes,
            repoUsuarios: context.read<RepoUsuarios>(),
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
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES')],
          theme: tema.themeData,
          initialRoute: Rutas.splash,
          routes: Rutas.mapaDeRutas(),
          onGenerateRoute: Rutas.generarRuta,
        ),
      ),
    );
  }
}
