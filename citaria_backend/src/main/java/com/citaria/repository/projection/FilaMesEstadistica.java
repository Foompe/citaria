package com.citaria.repository.projection;

/**
 * Proyección para estadísticas agrupadas por mes.
 */
public interface FilaMesEstadistica {
    String getPeriodo();
    Double getValor1();
    Double getValor2();
}