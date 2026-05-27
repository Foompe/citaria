import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/logo_citaria.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_chatbot.dart';

class PantallaChatbot extends StatefulWidget {
  const PantallaChatbot({super.key});

  @override
  State<PantallaChatbot> createState() => _PantallaChatbotState();
}

class _PantallaChatbotState extends State<PantallaChatbot> {
  final TextEditingController _controlador = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ViewModelChatbot>().inicializar();
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final String texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    _controlador.clear();
    await context.read<ViewModelChatbot>().enviarMensaje(texto);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatbot = context.watch<ViewModelChatbot>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Asistente', style: textTheme.displayLarge),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'En línea',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.padX,
                  vertical: 16,
                ),
                itemCount: chatbot.mensajes.length,
                itemBuilder: (context, i) =>
                    _BurbujaMensaje(mensaje: chatbot.mensajes[i]),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                color: colorScheme.surface,
                padding: EdgeInsets.fromLTRB(espaciado.padX, 8, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controlador,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviarMensaje(),
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu mensaje…',
                        ),
                      ),
                    ),
                    Semantics(
                      label: 'Enviar mensaje',
                      child: IconButton(
                        tooltip: 'Enviar',
                        icon: Icon(
                          Icons.send_rounded,
                          color: chatbot.cargando
                              ? colorScheme.outline
                              : colorScheme.primary,
                        ),
                        onPressed: chatbot.cargando ? null : _enviarMensaje,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurbujaMensaje extends StatelessWidget {
  const _BurbujaMensaje({required this.mensaje});

  final DtoMensajeChatbot mensaje;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool esUsuario = mensaje.esUsuario;
    final BorderRadius radio = esUsuario
        ? BorderRadius.only(
            topLeft: Radius.circular(espaciado.radioCard.topLeft.x),
            topRight: Radius.circular(espaciado.radioCard.topRight.x),
            bottomLeft: Radius.circular(espaciado.radioCard.bottomLeft.x),
            bottomRight: const Radius.circular(4),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(espaciado.radioCard.topLeft.x),
            topRight: Radius.circular(espaciado.radioCard.topRight.x),
            bottomLeft: const Radius.circular(4),
            bottomRight: Radius.circular(espaciado.radioCard.bottomRight.x),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario) ...[
            const LogoCitaria(tamano: LogoTamano.pequeno),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario
                    ? colorScheme.primary
                    : mensaje.error
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                borderRadius: radio,
              ),
              child: mensaje.enviando
                  ? const _AnimacionEscribiendo()
                  : Text(
                      mensaje.texto,
                      style: textTheme.bodyLarge?.copyWith(
                        color: esUsuario
                            ? colorScheme.onPrimary
                            : mensaje.error
                                ? colorScheme.onErrorContainer
                                : colorScheme.onSurface,
                      ),
                    ),
            ),
          ),
          if (esUsuario) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _AnimacionEscribiendo extends StatefulWidget {
  const _AnimacionEscribiendo();

  @override
  State<_AnimacionEscribiendo> createState() => _AnimacionEscribiendoState();
}

class _AnimacionEscribiendoState extends State<_AnimacionEscribiendo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.outline;
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final Animation<double> subida = TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
            TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
            TweenSequenceItem(tween: ConstantTween(0.0), weight: 1),
          ]).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(i * 0.15, (i * 0.15) + 0.5, curve: Curves.easeInOut),
          ));
          return AnimatedBuilder(
            animation: subida,
            builder: (_, _) => Transform.translate(
              offset: Offset(0, subida.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
