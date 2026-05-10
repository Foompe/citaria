package com.citaria.repository.projection;

/**
 * Proyección que usamos para las estadísticas de importe agrupadas por empleado o servicio
 */
public interface FilaImporteEstadistica {
    Integer getId();
    String getNombre();
    Double getImporte();
}