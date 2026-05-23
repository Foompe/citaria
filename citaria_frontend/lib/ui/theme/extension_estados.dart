import 'package:flutter/material.dart';

/// Par de colores (fondo + texto) para un estado de reserva.
@immutable
class ColoresEstado {
  const ColoresEstado({required this.fondo, required this.texto});

  final Color fondo;
  final Color texto;

  ColoresEstado lerp(ColoresEstado other, double t) => ColoresEstado(
    fondo: Color.lerp(fondo, other.fondo, t)!,
    texto: Color.lerp(texto, other.texto, t)!,
  );
}

/// Colores semánticos para los cuatro estados de reserva de Citaria.
///
/// Acceso: `Theme.of(context).extension<EstadosReservaCitaria>()!`
@immutable
class EstadosReservaCitaria extends ThemeExtension<EstadosReservaCitaria> {
  const EstadosReservaCitaria({
    required this.pendiente,
    required this.confirmada,
    required this.cancelada,
    required this.completada,
  });

  final ColoresEstado pendiente;
  final ColoresEstado confirmada;
  final ColoresEstado cancelada;
  final ColoresEstado completada;

  // ── Instancia base (tema claro) ────────────────────────────────────────────
  //
  // Conversión RGBA → ARGB hex:
  //   rgba(217,159,36 ,0.12) → alpha=31=0x1F  → 0x1FD99F24
  //   rgba(46 ,200,138,0.12) → alpha=31=0x1F  → 0x1F2EC88A
  //   rgba(214,71 ,71 ,0.12) → alpha=31=0x1F  → 0x1FD64747
  //   rgba(122,129,148,0.12) → alpha=31=0x1F  → 0x1F7A8194
  static const EstadosReservaCitaria base = EstadosReservaCitaria(
    pendiente: ColoresEstado(
      fondo: Color(0x33D99F24), // alpha 0x33 = 20% — amarillo visible
      texto: Color(0xFF7A5200), // marrón oscuro — contraste alto
    ),
    confirmada: ColoresEstado(
      fondo: Color(0x332EC88A), // alpha 0x33 = 20% — verde visible
      texto: Color(0xFF0D5C36), // verde oscuro — contraste alto
    ),
    cancelada: ColoresEstado(
      fondo: Color(0x33D64747), // alpha 0x33 = 20% — rojo visible
      texto: Color(0xFF7A1010), // rojo oscuro — contraste alto
    ),
    completada: ColoresEstado(
      fondo: Color(0x337A8194), // alpha 0x33 = 20% — gris visible
      texto: Color(0xFF3A3F4A), // gris oscuro — contraste alto
    ),
  );

  @override
  EstadosReservaCitaria copyWith({
    ColoresEstado? pendiente,
    ColoresEstado? confirmada,
    ColoresEstado? cancelada,
    ColoresEstado? completada,
  }) => EstadosReservaCitaria(
    pendiente: pendiente ?? this.pendiente,
    confirmada: confirmada ?? this.confirmada,
    cancelada: cancelada ?? this.cancelada,
    completada: completada ?? this.completada,
  );

  @override
  EstadosReservaCitaria lerp(
    ThemeExtension<EstadosReservaCitaria>? other,
    double t,
  ) {
    if (other is! EstadosReservaCitaria) return this;
    return EstadosReservaCitaria(
      pendiente: pendiente.lerp(other.pendiente, t),
      confirmada: confirmada.lerp(other.confirmada, t),
      cancelada: cancelada.lerp(other.cancelada, t),
      completada: completada.lerp(other.completada, t),
    );
  }
}
