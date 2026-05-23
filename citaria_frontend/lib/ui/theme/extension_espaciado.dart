import 'package:flutter/material.dart';

/// Valores de geometría propios de Citaria no cubiertos por [ThemeData].
///
/// Dispositivo de referencia: 390 × 844.
/// Acceso: `Theme.of(context).extension<EspaciadoCitaria>()!`
@immutable
class EspaciadoCitaria extends ThemeExtension<EspaciadoCitaria> {
  const EspaciadoCitaria({
    required this.radioPill,
    required this.radioInput,
    required this.radioCard,
    required this.radioBoton,
    required this.padX,
    required this.safeTop,
    required this.safeBottom,
  });

  // ── Radios ─────────────────────────────────────────────────────────────────
  final BorderRadius radioPill;
  final BorderRadius radioInput;
  final BorderRadius radioCard;
  final BorderRadius radioBoton;

  // ── Espaciado ──────────────────────────────────────────────────────────────
  final double padX;
  final double safeTop;
  final double safeBottom;

  // ── Instancia base ─────────────────────────────────────────────────────────
  static const EspaciadoCitaria base = EspaciadoCitaria(
    radioPill: BorderRadius.all(Radius.circular(999)),
    radioInput: BorderRadius.all(Radius.circular(12)),
    radioCard: BorderRadius.all(Radius.circular(16)),
    radioBoton: BorderRadius.all(Radius.circular(14)),
    padX: 20.0,
    safeTop: 48.0,
    safeBottom: 24.0,
  );

  @override
  EspaciadoCitaria copyWith({
    BorderRadius? radioPill,
    BorderRadius? radioInput,
    BorderRadius? radioCard,
    BorderRadius? radioBoton,
    double? padX,
    double? safeTop,
    double? safeBottom,
  }) => EspaciadoCitaria(
    radioPill: radioPill ?? this.radioPill,
    radioInput: radioInput ?? this.radioInput,
    radioCard: radioCard ?? this.radioCard,
    radioBoton: radioBoton ?? this.radioBoton,
    padX: padX ?? this.padX,
    safeTop: safeTop ?? this.safeTop,
    safeBottom: safeBottom ?? this.safeBottom,
  );

  @override
  EspaciadoCitaria lerp(ThemeExtension<EspaciadoCitaria>? other, double t) {
    if (other is! EspaciadoCitaria) return this;
    return EspaciadoCitaria(
      radioPill: BorderRadius.lerp(radioPill, other.radioPill, t)!,
      radioInput: BorderRadius.lerp(radioInput, other.radioInput, t)!,
      radioCard: BorderRadius.lerp(radioCard, other.radioCard, t)!,
      radioBoton: BorderRadius.lerp(radioBoton, other.radioBoton, t)!,
      padX: _lerpDouble(padX, other.padX, t),
      safeTop: _lerpDouble(safeTop, other.safeTop, t),
      safeBottom: _lerpDouble(safeBottom, other.safeBottom, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
