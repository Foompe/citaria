package com.citaria.dto;

/**
 * DTO de estadísticas agrupadas por mes.
 * Reutilizable para múltiples métricas mensuales.
 * periodo tiene formato "YYYY-MM" — el frontend construye la etiqueta legible.
 * valor1 y valor2 representan métricas distintas según el endpoint:
 * - nuevos-vs-recurrentes: valor1=nuevos, valor2=recurrentes
 * - fidelizacion: valor1=totalClientes, valor2=porcentajeRetencion
 */
public class EstadisticaMesDTO {

    private String periodo;
    private Double valor1;
    private Double valor2;

    public EstadisticaMesDTO(String periodo, Double valor1, Double valor2) {
        this.periodo = periodo;
        this.valor1 = valor1;
        this.valor2 = valor2;
    }

    public String getPeriodo() { return periodo; }
    public Double getValor1() { return valor1; }
    public Double getValor2() { return valor2; }
}