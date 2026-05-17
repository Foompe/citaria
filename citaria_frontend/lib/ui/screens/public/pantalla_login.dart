import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_tema.dart';

/// P04 — Login.
///
/// Formulario de inicio de sesión con email y contraseña.
/// Incluye toggle de visibilidad de contraseña y diálogo de
/// recuperación (D01) sin lógica real.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorPassword = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorPassword.dispose();
    super.dispose();
  }

  void _mostrarDialogoRecuperacion(BuildContext context) {
    final TextEditingController controladorEmailRecup = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Introduce tu email y te enviaremos las instrucciones.',
              style: Theme.of(dialogContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controladorEmailRecup,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'tu@email.com',
                labelText: 'Email',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Enviar'),
          ),
        ],
      ),
    ).then((_) => controladorEmailRecup.dispose());
  }

  Future<void> _iniciarSesion() async {
    final vmAuth = context.read<ViewModelAutenticacion>();
    final vmTema = context.read<ViewModelTema>();
    final destino = await vmAuth.iniciarSesion(
      email: _controladorEmail.text.trim(),
      password: _controladorPassword.text,
      tema: vmTema,
    );

    if (!mounted) return;

    final String? mensajeError = vmAuth.error;
    if (destino != null) {
      GestorNavegacion.irASplashPostAutenticacion(context);
    } else if (mensajeError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensajeError)));
    }
  }

  // ── BOTONES TESTING ───────────────────────────────────────────

  void _entrarComoAdmin() {
    GestorNavegacion.irAHomeAdmin(context);
  }

  void _entrarComoCliente() {
    GestorNavegacion.irAHomeCliente(context);
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vmAuth = context.watch<ViewModelAutenticacion>();
    final empresaActiva = vmAuth.empresaActiva;
    final String nombreEmpresa = empresaActiva?.nombre ?? 'Citaria';

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const CabeceraPantalla(titulo: 'Iniciar sesión'),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            espaciado.padX,
            24,
            espaciado.padX,
            espaciado.safeBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: AvatarFallbackCitaria(
                  texto: nombreEmpresa,
                  imagenUrl: empresaActiva?.logoUrl,
                  tamano: 96,
                  radio: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nombreEmpresa,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              Text('Email', style: textTheme.bodySmall),
              const SizedBox(height: 6),
              TextField(
                controller: _controladorEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'tu@email.com'),
              ),
              const SizedBox(height: 16),
              Text('Contraseña', style: textTheme.bodySmall),
              const SizedBox(height: 6),
              TextField(
                controller: _controladorPassword,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    tooltip: _passwordVisible
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _mostrarDialogoRecuperacion(context),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: vmAuth.cargando ? null : _iniciarSesion,
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('o', style: textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => GestorNavegacion.irARegistro(context),
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodySmall,
                      children: [
                        const TextSpan(text: '¿No tienes cuenta? '),
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── BOTONES TESTING ───────────────────────────────────────────
              // TODO: eliminar antes de producción
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _entrarComoAdmin,
                    child: const Text('Entrar como Admin'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _entrarComoCliente,
                    child: const Text('Entrar como Cliente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
