package com.citaria.dto;

import java.math.BigDecimal;

/**
 * DTO de resumen estadístico del negocio.
 */
public class ResumenEstadisticaDTO {

    private Long reservasHoy;
    private Long reservasMes;
    private BigDecimal facturacionHoy;
    private BigDecimal facturacionMes;
    private Long clientesNuevosMes;
    private String servicioMasSolicitadoMes;

    public ResumenEstadisticaDTO(Long reservasHoy, Long reservasMes,
                                 BigDecimal facturacionHoy, BigDecimal facturacionMes,
                                 Long clientesNuevosMes, String servicioMasSolicitadoMes) {
        this.reservasHoy = reservasHoy;
        this.reservasMes = reservasMes;
        this.facturacionHoy = facturacionHoy;
        this.facturacionMes = facturacionMes;
        this.clientesNuevosMes = clientesNuevosMes;
        this.servicioMasSolicitadoMes = servicioMasSolicitadoMes;
    }

    public Long getReservasHoy() { return reservasHoy; }
    public Long getReservasMes() { return reservasMes; }
    public BigDecimal getFacturacionHoy() { return facturacionHoy; }
    public BigDecimal getFacturacionMes() { return facturacionMes; }
    public Long getClientesNuevosMes() { return clientesNuevosMes; }
    public String getServicioMasSolicitadoMes() { return servicioMasSolicitadoMes; }
}