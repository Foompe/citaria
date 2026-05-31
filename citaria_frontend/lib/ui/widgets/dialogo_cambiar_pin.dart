import 'package:citaria_frontend/data/services/servicio_pin.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/teclado_pin_citaria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _Paso { actual, nuevo, confirmar }

/// Diálogo de cambio de PIN en tres pasos:
/// 1. Introduce el PIN actual.
/// 2. Introduce el nuevo PIN.
/// 3. Confirma el nuevo PIN.
///
/// Devuelve true al guardar correctamente, false si el usuario cancela.
class DialogoCambiarPin extends StatefulWidget {
  const DialogoCambiarPin({super.key});

  @override
  State<DialogoCambiarPin> createState() => _DialogoCambiarPinState();
}

class _DialogoCambiarPinState extends State<DialogoCambiarPin> {
  _Paso _paso = _Paso.actual;
  final List<int> _digitos = [];
  String _pinNuevo = '';
  bool _guardando = false;
  bool _pinInvalido = false;

  static const int _minDigitos = 4;
  static const int _maxDigitos = 8;

  bool get _puedeConfirmar =>
      _digitos.length >= _minDigitos && !_guardando && !_pinInvalido;

  void _pulsarDigito(int d) {
    if (_digitos.length >= _maxDigitos || _pinInvalido) return;
    setState(() => _digitos.add(d));
  }

  void _borrarDigito() {
    if (_digitos.isEmpty) return;
    setState(() => _digitos.removeLast());
  }

  Future<void> _confirmar() async {
    if (!_puedeConfirmar) return;
    final String pin = _digitos.join();

    switch (_paso) {
      case _Paso.actual:
        setState(() => _guardando = true);
        final bool ok = await context.read<ServicioPin>().verificar(pin);
        if (!mounted) return;
        if (ok) {
          setState(() {
            _guardando = false;
            _paso = _Paso.nuevo;
            _digitos.clear();
          });
        } else {
          _mostrarError();
        }

      case _Paso.nuevo:
        setState(() {
          _pinNuevo = pin;
          _paso = _Paso.confirmar;
          _digitos.clear();
        });

      case _Paso.confirmar:
        if (pin != _pinNuevo) {
          _mostrarError();
          return;
        }
        setState(() => _guardando = true);
        await context.read<ServicioPin>().cambiar(pin);
        if (!mounted) return;
        Navigator.of(context).pop(true);
    }
  }

  void _mostrarError() {
    setState(() {
      _guardando = false;
      _pinInvalido = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _pinInvalido = false;
          _digitos.clear();
        });
      }
    });
  }

  void _cancelar() => Navigator.of(context).pop(false);

  String get _tituloPaso {
    switch (_paso) {
      case _Paso.actual:    return 'PIN actual';
      case _Paso.nuevo:     return 'PIN nuevo';
      case _Paso.confirmar: return 'Confirmar PIN';
    }
  }

  String get _subtituloPaso {
    switch (_paso) {
      case _Paso.actual:    return 'Introduce tu PIN actual para continuar.';
      case _Paso.nuevo:     return 'Elige un PIN entre 4 y 8 dígitos.';
      case _Paso.confirmar: return 'Repite el nuevo PIN para confirmarlo.';
    }
  }

  String get _mensajeError {
    switch (_paso) {
      case _Paso.actual:    return 'PIN incorrecto';
      case _Paso.nuevo:     return '';
      case _Paso.confirmar: return 'Los PINs no coinciden';
    }
  }

  @override
  Widget build(BuildContext context) {
    final espaciado   = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con icono y pasos
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: espaciado.radioCard,
                ),
                child: Icon(
                  Icons.lock_reset_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              _IndicadorPasos(pasoActual: _paso.index),
            ],
          ),
          const SizedBox(height: 16),

          Text('Cambiar PIN', style: textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            _tituloPaso,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _subtituloPaso,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 20),

          // Indicadores de punto
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_maxDigitos, (i) {
                final bool relleno = i < _digitos.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinInvalido && relleno
                          ? colorScheme.error
                          : relleno
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Mensaje de error
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: (_pinInvalido && _mensajeError.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        _mensajeError,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          TecladoPinCitaria(
            onDigito: _pulsarDigito,
            onBorrar: _borrarDigito,
            onConfirmar: _puedeConfirmar ? _confirmar : null,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _guardando ? null : _cancelar,
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}

// Indicador de pasos

class _IndicadorPasos extends StatelessWidget {
  const _IndicadorPasos({required this.pasoActual});

  final int pasoActual;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final bool activo = i == pasoActual;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: activo ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i <= pasoActual
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }
}
