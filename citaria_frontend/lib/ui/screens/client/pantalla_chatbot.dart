import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
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
      appBar: CabeceraPantalla(
        mostrarAtras: true,
        titulo: 'Asistente',
        accionDerecha: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
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
        ),
      ),
      body: Column(
        children: [
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
          Container(
            color: colorScheme.surface,
            padding: EdgeInsets.fromLTRB(
              espaciado.padX,
              8,
              8,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
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
        ],
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
        mainAxisAlignment: esUsuario
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
              child: Text(
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
