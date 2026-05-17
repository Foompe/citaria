class ResumenEstadistica {
  final int? reservasHoy;
  final int? reservasMes;
  final double? facturacionHoy;
  final double? facturacionMes;
  final int? clientesNuevosMes;
  final String? servicioMasSolicitadoMes;

  const ResumenEstadistica({
    this.reservasHoy,
    this.reservasMes,
    this.facturacionHoy,
    this.facturacionMes,
    this.clientesNuevosMes,
    this.servicioMasSolicitadoMes,
  });

  factory ResumenEstadistica.fromJson(Map<String, dynamic> json) {
    return ResumenEstadistica(
      reservasHoy: json['reservasHoy'] == null
          ? null
          : (json['reservasHoy'] as num).toInt(),
      reservasMes: json['reservasMes'] == null
          ? null
          : (json['reservasMes'] as num).toInt(),
      facturacionHoy: json['facturacionHoy'] == null
          ? null
          : (json['facturacionHoy'] as num).toDouble(),
      facturacionMes: json['facturacionMes'] == null
          ? null
          : (json['facturacionMes'] as num).toDouble(),
      clientesNuevosMes: json['clientesNuevosMes'] == null
          ? null
          : (json['clientesNuevosMes'] as num).toInt(),
      servicioMasSolicitadoMes: json['servicioMasSolicitadoMes'] as String?,
    );
  }
}
