package com.citaria.dto;

/**
 * DTO de estadísticas agrupadas por servicio.
 * Reutilizable para múltiples métricas de rendimiento:
 * - mas-solicitados: valor=totalReservas, porcentaje=null
 * - importe: valor=importeTotal, porcentaje=null
 * - cancelaciones: valor=totalCanceladas, porcentaje=tasaCancelacion
 */
public class EstadisticaServicioDTO {

    private Integer servicioId;
    private String nombre;
    private Double valor;
    private Double porcentaje;

    public EstadisticaServicioDTO(Integer servicioId, String nombre, Double valor, Double porcentaje) {
        this.servicioId = servicioId;
        this.nombre = nombre;
        this.valor = valor;
        this.porcentaje = porcentaje;
    }

    public Integer getServicioId() { return servicioId; }
    public String getNombre() { return nombre; }
    public Double getValor() { return valor; }
    public Double getPorcentaje() { return porcentaje; }
}