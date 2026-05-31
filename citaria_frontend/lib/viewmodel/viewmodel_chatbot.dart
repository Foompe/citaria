import 'package:citaria_frontend/data/models/chatbot.dart';
import 'package:citaria_frontend/data/models/sesion.dart';
import 'package:citaria_frontend/data/repositories/repo_chatbot.dart';
import 'package:citaria_frontend/dto/dto_mensaje_chatbot.dart';
import 'package:citaria_frontend/viewmodel/viewmodel_autenticacion.dart';
import 'package:flutter/foundation.dart';

/// Gestiona la conversación del cliente con el chatbot y sus mensajes.
class ViewModelChatbot extends ChangeNotifier {
  ViewModelChatbot({
    required RepoChatbot repoChatbot,
    required ViewModelAutenticacion autenticacion,
  }) : _repoChatbot = repoChatbot,
       _autenticacion = autenticacion;

  final RepoChatbot _repoChatbot;
  final ViewModelAutenticacion _autenticacion;

  bool _cargando = false;
  String? _error;
  List<DtoMensajeChatbot> _mensajes = const <DtoMensajeChatbot>[];

  bool get cargando => _cargando;
  String? get error => _error;
  List<DtoMensajeChatbot> get mensajes => _mensajes;

  void inicializar() {
    if (_mensajes.isNotEmpty) return;
    _mensajes = const <DtoMensajeChatbot>[
      DtoMensajeChatbot(
        texto: '¡Hola! Soy tu asistente Citaria. ¿En qué puedo ayudarte?',
        esUsuario: false,
        enviando: false,
        error: false,
      ),
    ];
    notifyListeners();
  }

  Future<void> enviarMensaje(String texto) async {
    final String pregunta = texto.trim();
    if (pregunta.isEmpty) return;

    _cargando = true;
    _error = null;
    _mensajes = <DtoMensajeChatbot>[
      ..._mensajes,
      DtoMensajeChatbot(
        texto: pregunta,
        esUsuario: true,
        enviando: false,
        error: false,
      ),
      const DtoMensajeChatbot(
        texto: '',
        esUsuario: false,
        enviando: true,
        error: false,
      ),
    ];
    notifyListeners();

    try {
      final Sesion sesion = _leerSesionAutenticada();
      final Chatbot respuesta = await _repoChatbot.preguntar(
        pregunta,
        sesion.token,
      );
      _mensajes = <DtoMensajeChatbot>[
        ..._mensajes.sublist(0, _mensajes.length - 1),
        DtoMensajeChatbot(
          texto: respuesta.respuesta ?? 'No he podido generar una respuesta.',
          esUsuario: false,
          enviando: false,
          error: false,
        ),
      ];
      notifyListeners();
    } catch (e) {
      final String mensaje = _mensajeError(e);
      _error = mensaje;
      _mensajes = <DtoMensajeChatbot>[
        ..._mensajes.sublist(0, _mensajes.length - 1),
        DtoMensajeChatbot(
          texto: mensaje,
          esUsuario: false,
          enviando: false,
          error: true,
        ),
      ];
      notifyListeners();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _mensajes = const <DtoMensajeChatbot>[];
    _cargando = false;
    _error = null;
    inicializar();
  }

  void limpiarConversacion() {
    _mensajes = const <DtoMensajeChatbot>[];
    inicializar();
  }

  Sesion _leerSesionAutenticada() {
    final Sesion? sesion = _autenticacion.obtenerSesion();
    if (sesion == null || sesion.token.isEmpty) {
      throw StateError('Sesión no disponible.');
    }
    return sesion;
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }
}
