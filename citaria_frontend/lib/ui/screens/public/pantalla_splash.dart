import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/hero_logo_citaria.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_tema.dart';

/// Pantalla de Splash.
///
/// Muestra logo + barra de progreso animada mientras se verifica
/// la sesión. Al terminar navega segú el resultado del ViewModel.
class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key, this.duracionMinima = true});

  final bool duracionMinima;

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorProgreso;
  late final Animation<double> _animacionProgreso;
  bool _hayEmpresaSeleccionada = false;

  @override
  void initState() {
    super.initState();

    _controladorProgreso = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animacionProgreso = CurvedAnimation(
      parent: _controladorProgreso,
      curve: Curves.easeInOut,
    );

    _controladorProgreso.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmAuth = context.read<ViewModelAutenticacion>();
      final vmTema = context.read<ViewModelTema>();

      _hayEmpresaSeleccionada = vmAuth.hayEmpresaSeleccionada;
      if (mounted) {
        setState(() {});
      }

      final destino = await _cargarArranque(vmAuth: vmAuth, vmTema: vmTema);

      if (!mounted) return;
      _navegarSegunDestino(destino);
    });
  }

  @override
  void dispose() {
    _controladorProgreso.dispose();
    super.dispose();
  }

  Future<DestinoAutenticacion> _cargarArranque({
    required ViewModelAutenticacion vmAuth,
    required ViewModelTema vmTema,
  }) async {
    if (!mounted) return DestinoAutenticacion.seleccionEmpresa;
    await vmTema.inicializar();

    if (!mounted) return DestinoAutenticacion.seleccionEmpresa;
    final Future<DestinoAutenticacion> cargaSesion = vmAuth.verificarSesion(
      tema: vmTema,
    );

    if (!widget.duracionMinima) {
      return cargaSesion;
    }

    final resultados = await Future.wait<Object?>([
      cargaSesion,
      Future<Object?>.delayed(const Duration(seconds: 3)),
    ]);

    return resultados.first as DestinoAutenticacion;
  }

  void _navegarSegunDestino(DestinoAutenticacion destino) {
    switch (destino) {
      case DestinoAutenticacion.seleccionEmpresa:
        GestorNavegacion.irASeleccionEmpresaDesdeSplash(context);
        return;
      case DestinoAutenticacion.login:
        GestorNavegacion.irALogin(context);
        return;
      case DestinoAutenticacion.homeCliente:
        GestorNavegacion.irAHomeCliente(context);
        return;
      case DestinoAutenticacion.homeAdmin:
        GestorNavegacion.irAHomeAdmin(context);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final empresaActiva = context.watch<ViewModelAutenticacion>().empresaActiva;
    final logoTema = context.watch<ViewModelTema>().datos?.logoUrl;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: espaciado.padX),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: heroLogoCitaria,
                      child: _LogoSplash(
                        hayEmpresaSeleccionada: _hayEmpresaSeleccionada,
                        nombreEmpresa: empresaActiva?.nombre,
                        logoUrl: logoTema,
                        animacionProgreso: _animacionProgreso,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Cargando…', style: textTheme.bodySmall),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 40,
                  right: 40,
                  bottom: espaciado.safeBottom,
                ),
                child: AnimatedBuilder(
                  animation: _animacionProgreso,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _hayEmpresaSeleccionada
                        ? null
                        : _animacionProgreso.value,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoSplash extends StatelessWidget {
  const _LogoSplash({
    required this.hayEmpresaSeleccionada,
    required this.nombreEmpresa,
    required this.logoUrl,
    required this.animacionProgreso,
  });

  final bool hayEmpresaSeleccionada;
  final String? nombreEmpresa;
  final String? logoUrl;
  final Animation<double> animacionProgreso;

  @override
  Widget build(BuildContext context) {
    if (!hayEmpresaSeleccionada) {
      return RotationTransition(
        turns: animacionProgreso,
        child: Image.asset(
          'assets/images/logo_citaria.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      );
    }

    final String textoEmpresa = nombreEmpresa ?? 'Citaria';
    final String? logoEmpresa = logoUrl?.trim();
    if (logoEmpresa != null && logoEmpresa.isNotEmpty) {
      return SizedBox(
        width: 160,
        height: 160,
        child: Image.network(
          logoEmpresa,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => AvatarFallbackCitaria(
            texto: textoEmpresa,
            tamano: 160,
            radio: 32,
          ),
        ),
      );
    }

    return AvatarFallbackCitaria(texto: textoEmpresa, tamano: 160, radio: 32);
  }
}
