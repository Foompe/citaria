import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/navigation/rutas.dart';
import 'package:citaria_frontend/ui/navigation/sesion_pin.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_empleados.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_nuevo_empleado.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_detalle_empleado.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_catalogo.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_nuevo_servicio.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_horarios.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_estadisticas.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_ajustes.dart';
import 'package:citaria_frontend/ui/screens/public/pantalla_seleccion_empresa.dart';
import 'package:citaria_frontend/ui/widgets/dialogo_pin.dart';
import 'package:citaria_frontend/ui/screens/admin/pantalla_admin_reservas.dart';

/// Punto único de navegación de la aplicación Citaria.
///
/// Todos los métodos son estáticos y reciben el [BuildContext] del widget
/// que origina la navegación. Nadie usa strings de ruta directamente
/// fuera de esta clase y de [Rutas].
///
/// Las rutas protegidas por PIN navegan a través de [_irAPinConDestino],
/// que consulta [SesionPin] antes de mostrar el diálogo. Si la sesión
/// está activa, navega directamente sin pedir el PIN.
/// Los métodos que salen del área protegida llaman a [SesionPin.invalidar].
class GestorNavegacion {
  GestorNavegacion._();

  // ── ÁREA PÚBLICA ──────────────────────────────────────────────────────────

  static void irASplash(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.splash);

  static void irASeleccionEmpresaDesdeSplash(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 1600),
        reverseTransitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => const PantallaSeleccionEmpresa(),
        transitionsBuilder: (_, animation, _, child) {
          final fadePantalla = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
          );

          return FadeTransition(opacity: fadePantalla, child: child);
        },
      ),
      (route) => false,
    );
  }

  static void irASeleccionEmpresa(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.seleccionEmpresa);

  static void irALogin(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.login);

  static void irARegistro(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.registro);

  static void irAVincularCuenta(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.vincularCuenta);

  // ── POST-AUTENTICACIÓN (limpian la pila completa) ─────────────────────────

  static void irAHomeCliente(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.inicioCliente,
        (route) => false,
      );

  static void irAInicioCliente(BuildContext context) =>
      Navigator.pushReplacementNamed(context, Rutas.inicioCliente);

  static void irAHomeAdmin(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Rutas.adminInicio,
      (route) => false,
    );
  }

  static void irACambiarEmpresa(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.seleccionEmpresa,
        (route) => false,
      );

  static void irACerrarSesion(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (route) => false);
  }

  // ── ÁREA CLIENTE ──────────────────────────────────────────────────────────

  static void irACatalogo(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.catalogoCliente);

  static void irADetalleServicio(BuildContext context, String id) =>
      Navigator.pushNamed(
        context,
        Rutas.detalleServicio,
        arguments: {'id': id},
      );

  static void irAWizardServicios(
    BuildContext context, {
    String? servicioPreseleccionado,
  }) => Navigator.pushNamed(
    context,
    Rutas.wizardServicios,
    arguments: {'servicioPreseleccionado': servicioPreseleccionado},
  );

  static void irAWizardEmpleado(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.wizardEmpleado);

  static void irAWizardFecha(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.wizardFecha);

  static void irAWizardHora(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.wizardHora);

  static void irAWizardConfirmar(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.wizardConfirmar);

  static void irAMisReservas(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.misReservas);

  static void irADetalleReservaCliente(BuildContext context, String id) =>
      Navigator.pushNamed(
        context,
        Rutas.detalleReservaCliente,
        arguments: {'id': id},
      );

  static void irAPerfil(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.perfil);

  static void irAChatbot(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.chatbot);

  static void confirmarWizard(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.inicioCliente,
        (route) => false,
      );

  static void cancelarWizard(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.inicioCliente,
        (route) => false,
      );

  // ── ÁREA ADMIN — COMÚN ────────────────────────────────────────────────────

  static void irAAdminInicio(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamed(context, Rutas.adminInicio);
  }

  static void irAAdminReservas(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamed(context, Rutas.adminReservas);
  }

  static void irAAdminReservasPendientes(BuildContext context) {
    SesionPin.invalidar();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PantallaAdminReservas(
          filtroInicial: FiltroReservasAdmin.pendientes,
        ),
      ),
    );
  }

  static void irAAdminDetalleReserva(BuildContext context, String id) =>
      Navigator.pushNamed(
        context,
        Rutas.adminDetalleReserva,
        arguments: {'id': id},
      );

  static void irAAdminSeleccionCliente(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.adminSeleccionCliente);

  static void irAAdminClientes(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamed(context, Rutas.adminClientes);
  }

  static void irAAdminNuevoCliente(BuildContext context) =>
      Navigator.pushNamed(context, Rutas.adminNuevoCliente);

  static void irAAdminDetalleCliente(BuildContext context, String id) =>
      Navigator.pushNamed(
        context,
        Rutas.adminDetalleCliente,
        arguments: {'id': id},
      );

  static void irAAdminCalendario(BuildContext context) {
    SesionPin.invalidar();
    Navigator.pushNamed(context, Rutas.adminCalendario);
  }

  // ── ÁREA ADMIN — PROTEGIDA PIN ────────────────────────────────────────────

  /// Núcleo de la navegación protegida.
  ///
  /// Si [SesionPin.estaActiva], navega directamente.
  /// Si no, muestra [DialogoPin]. Al validar, activa la sesión y navega.
  /// Si el usuario cancela, no ocurre nada.
  static Future<void> _irAPinConDestino(
    BuildContext context,
    WidgetBuilder builder,
    String nombreSeccion,
  ) async {
    if (SesionPin.estaActiva) {
      Navigator.push(context, MaterialPageRoute(builder: builder));
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogoPin(seccion: nombreSeccion),
    );

    if (ok == true) {
      SesionPin.activar();
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: builder));
      }
    }
  }

  static Future<void> irAAdminEmpleados(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminEmpleados(),
        'Empleados',
      );

  static Future<void> irAAdminNuevoEmpleado(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminNuevoEmpleado(),
        'Empleados',
      );

  static Future<void> irAAdminDetalleEmpleado(
    BuildContext context,
    String id,
  ) => _irAPinConDestino(
    context,
    (_) => const PantallaAdminDetalleEmpleado(),
    'Empleados',
  );

  static Future<void> irAAdminCatalogo(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminCatalogo(),
        'Catálogo',
      );

  static Future<void> irAAdminNuevoServicio(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminNuevoServicio(),
        'Catálogo',
      );

  static Future<void> irAAdminHorarios(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminHorarios(),
        'Horarios',
      );

  static Future<void> irAAdminEstadisticas(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminEstadisticas(),
        'Estadísticas',
      );

  static Future<void> irAAdminAjustes(BuildContext context) =>
      _irAPinConDestino(
        context,
        (_) => const PantallaAdminAjustes(),
        'Ajustes',
      );
}
