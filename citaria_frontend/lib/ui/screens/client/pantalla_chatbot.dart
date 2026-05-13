import 'package:flutter/material.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_pantalla.dart';
import 'package:citaria_frontend/ui/widgets/logo_citaria.dart';

/// Origen de un mensaje en el chat.
enum _OrigenMensaje { usuario, bot }

/// Modelo de mensaje local del chatbot.
class _Mensaje {
  const _Mensaje({required this.texto, required this.origen});
  final String        texto;
  final _OrigenMensaje origen;
}

/// Pantalla del asistente chatbot (P11).
///
/// StatefulWidget: gestiona la lista de mensajes local y el
/// controlador de texto del campo de entrada.
///
/// HARDCODING TEMPORAL:
///   - Respuesta del bot: fija → TODO: conectar API del chatbot
class PantallaChatbot extends StatefulWidget {
  const PantallaChatbot({super.key});

  @override
  State<PantallaChatbot> createState() => _PantallaChatbotState();
}

class _PantallaChatbotState extends State<PantallaChatbot> {
  final TextEditingController _controlador = TextEditingController();
  final ScrollController      _scroll      = ScrollController();

  // TODO: persistir historial de mensajes si se requiere en Capa 3
  final List<_Mensaje> _mensajes = [
    const _Mensaje(
      texto: '¡Hola! Soy tu asistente Citaria. ¿En qué puedo ayudarte?',
      origen: _OrigenMensaje.bot,
    ),
  ];

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add(_Mensaje(texto: texto, origen: _OrigenMensaje.usuario));
      // TODO: conectar API del chatbot — reemplazar respuesta hardcodeada
      _mensajes.add(
        const _Mensaje(
          texto: 'Recibido. En breve te respondo.',
          origen: _OrigenMensaje.bot,
        ),
      );
    });

    _controlador.clear();
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
    final espaciado  = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme  = Theme.of(context).textTheme;

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
          // ── Lista de mensajes ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.padX,
                vertical: 16,
              ),
              itemCount: _mensajes.length,
              itemBuilder: (context, i) =>
                  _BurbujaMensaje(mensaje: _mensajes[i]),
            ),
          ),

          // ── Barra de entrada ───────────────────────────────────────────
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
                      color: colorScheme.primary,
                    ),
                    onPressed: _enviarMensaje,
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

// ── Widgets privados ──────────────────────────────────────────────────────────

class _BurbujaMensaje extends StatelessWidget {
  const _BurbujaMensaje({required this.mensaje});

  final _Mensaje mensaje;

  @override
  Widget build(BuildContext context) {
    final espaciado  = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme  = Theme.of(context).textTheme;

    final esUsuario = mensaje.origen == _OrigenMensaje.usuario;

    // Radio asimétrico según origen del mensaje
    final radio = esUsuario
        ? BorderRadius.only(
            topLeft:     Radius.circular(espaciado.radioCard.topLeft.x),
            topRight:    Radius.circular(espaciado.radioCard.topRight.x),
            bottomLeft:  Radius.circular(espaciado.radioCard.bottomLeft.x),
            bottomRight: const Radius.circular(4),
          )
        : BorderRadius.only(
            topLeft:     Radius.circular(espaciado.radioCard.topLeft.x),
            topRight:    Radius.circular(espaciado.radioCard.topRight.x),
            bottomLeft:  const Radius.circular(4),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: esUsuario
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: radio,
              ),
              child: Text(
                mensaje.texto,
                style: textTheme.bodyLarge?.copyWith(
                  color: esUsuario
                      ? colorScheme.onPrimary
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