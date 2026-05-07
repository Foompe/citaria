import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/hero_logo_citaria.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';

/// P01 — Splash.
///
/// Muestra logo + barra de progreso animada mientras se verifica
/// la sesión. Al terminar navega según el resultado del ViewModel.
class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorProgreso;
  late final Animation<double> _animacionProgreso;

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
      final viewModel = context.read<ViewModelAutenticacion>();

      // TODO: eliminar en producción — delay artificial para simular carga.
      await Future.wait([
        viewModel.verificarSesion(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      if (!mounted) return;

      // TODO: conectar ViewModel — cuando verificarSesion() esté
      // implementada, leer viewModel.estaAutenticado y viewModel.esAdmin
      // para decidir la ruta. Además, verificar si existe empresa
      // guardada en local storage.
      //
      // Lógica esperada:
      //   sin empresa guardada  → irASeleccionEmpresa
      //   empresa + sin sesión  → irALogin
      //   autenticado + cliente → irAHomeCliente
      //   autenticado + admin   → irAHomeAdmin
      //
      // Provisional: siempre navega a selección de empresa.
      GestorNavegacion.irASeleccionEmpresaDesdeSplash(context);
    });
  }

  @override
  void dispose() {
    _controladorProgreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                      child: RotationTransition(
                        turns: _animacionProgreso,
                        child: Image.asset(
                          'assets/images/logo_citaria.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
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
                    value: _animacionProgreso.value,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.12),
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
