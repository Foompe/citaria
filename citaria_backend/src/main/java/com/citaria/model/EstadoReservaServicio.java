package com.citaria.model;

/**
 * Estados posibles de una línea de detalle de una reserva.
 * Permite registrar cancelaciones individuales de servicios
 * para su uso en estadísticas e informes.
 */
public enum EstadoReservaServicio {
    activo,
    cancelado
}