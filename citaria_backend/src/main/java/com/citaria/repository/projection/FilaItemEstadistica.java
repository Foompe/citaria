package com.citaria.repository.projection;

/**
 * Proyección que usamos para estadísticas agrupadas por empleado o servicio incluyen totales y cancelaciones.
 */
public interface FilaItemEstadistica {
    Integer getId();
    String getNombre();
    Double getTotal();
    Double getCanceladas();
}