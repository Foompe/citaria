import 'package:flutter/widgets.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_splash.dart';
// ── Bloque 4: área admin común ────────────────────────────────────────────────
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_inicio.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_reservas.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_seleccion_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_clientes.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_nuevo_cliente.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_calendario.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_seleccion_empresa.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_login.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_registro.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_vincular_cuenta.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_inicio_cliente.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_catalogo_cliente.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_mis_reservas.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_perfil.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_chatbot.dart';
// ── Bloque 3: wizard de reserva ───────────────────────────────────────────────
import 'package:citaria_frontend/ui/screens/client/pantalla_wizard_servicios.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_wizard_empleado.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_wizard_fecha.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_wizard_hora.dart';
import 'package:citaria_frontend/ui/screens/client/pantalla_wizard_confirmar.dart';

/// Inventario centralizado de rutas
///
/// Las pantallas protegidas por PIN no tienen ruta nombrada ni entrada
/// en [mapaDeRutas]. La navegación a ellas ocurre exclusivamente a través
/// de [GestorNavegacion], que gestiona el diálogo PIN y la sesión.
class Rutas {
  Rutas._();

  // ── ÁREA PÚBLICA
  static const String splash = '/splash';
  static const String seleccionEmpresa = '/seleccion-empresa';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String vincularCuenta = '/vincular-cuenta';

  // ── ÁREA CLIENTE
  static const String inicioCliente = '/inicio';
  static const String catalogoCliente = '/catalogo';

  /// Solo constante — lleva segmento :id.
  static const String detalleServicio = '/servicio/:id';

  static const String wizardServicios = '/nueva-reserva/servicios';
  static const String wizardEmpleado = '/nueva-reserva/empleado';
  static const String wizardFecha = '/nueva-reserva/fecha';
  static const String wizardHora = '/nueva-reserva/hora';
  static const String wizardConfirmar = '/nueva-reserva/confirmar';
  static const String misReservas = '/mis-reservas';

  /// Solo constante — lleva segmento :id.
  static const String detalleReservaCliente = '/reserva/:id';

  static const String perfil = '/perfil';
  static const String chatbot = '/chatbot';

  // ── ÁREA ADMIN — COMÚN
  static const String adminInicio = '/admin/inicio';
  static const String adminReservas = '/admin/reservas';

  /// Solo constante — lleva segmento :id. No incluida en [mapaDeRutas].
  static const String adminDetalleReserva = '/admin/reservas/:id';

  static const String adminSeleccionCliente = '/admin/nueva-reserva/cliente';
  static const String adminClientes = '/admin/clientes';
  static const String adminNuevoCliente = '/admin/clientes/nuevo';

  /// Solo constante — lleva segmento :id. No incluida en [mapaDeRutas].
  static const String adminDetalleCliente = '/admin/clientes/:id';

  static const String adminCalendario = '/admin/calendario';

  // Las pantallas protegidas por PIN no tienen constante de ruta.
  // Ver GestorNavegacion para la navegación a estas secciones.

  /// Devuelve el mapa registrable en [MaterialApp.routes].
  static Map<String, WidgetBuilder> mapaDeRutas() {
    return <String, WidgetBuilder>{
      // ── Área pública (Bloque 1) ───────────────────────────────────────────
      splash: (_) => const PantallaSplash(),
      seleccionEmpresa: (_) => const PantallaSeleccionEmpresa(),
      login: (_) => const PantallaLogin(),
      registro: (_) => const PantallaRegistro(),
      vincularCuenta: (_) => const PantallaVincularCuenta(),

      // ── Área cliente (Bloque 2) ───────────────────────────────────────────
      inicioCliente: (_) => const PantallaInicioCliente(),
      catalogoCliente: (_) => const PantallaCatalogoCliente(),
      misReservas: (_) => const PantallaMisReservas(),
      perfil: (_) => const PantallaPerfil(),
      chatbot: (_) => const PantallaChatbot(),

      // ── Wizard de reserva (Bloque 3) ─────────────────────────────────────
      wizardServicios: (_) => const PantallaWizardServicios(),
      wizardEmpleado: (_) => const PantallaWizardEmpleado(),
      wizardFecha: (_) => const PantallaWizardFecha(),
      wizardHora: (_) => const PantallaWizardHora(),
      wizardConfirmar: (_) => const PantallaWizardConfirmar(),

      // ── Área admin — común (Bloque 4) ────────────────────────────────────
      adminInicio: (_) => const PantallaAdminInicio(),
      adminReservas: (_) => const PantallaAdminReservas(),
      adminSeleccionCliente: (_) => const PantallaAdminSeleccionCliente(),
      adminClientes: (_) => const PantallaAdminClientes(),
      adminNuevoCliente: (_) => const PantallaAdminNuevoCliente(),
      adminCalendario: (_) => const PantallaAdminCalendario(),

      // Las pantallas protegidas por PIN no tienen entrada aquí.
      // Ver GestorNavegacion.irAAdminEmpleados y equivalentes.
    };
  }
}
