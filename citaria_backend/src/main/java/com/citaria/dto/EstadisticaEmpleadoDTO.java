package com.citaria.dto;

/**
 * DTO de estadísticas agrupadas por empleado.
 * Reutilizable para múltiples métricas de rendimiento:
 * - reservas: valor=totalReservas, porcentaje=porcentajeCancelacion
 * - importe: valor=importeTotal, porcentaje=null
 * - cancelaciones: valor=totalCanceladas, porcentaje=porcentajeCancelacion
 */
public class EstadisticaEmpleadoDTO {

    private Integer empleadoId;
    private String nombre;
    private Double valor;
    private Double porcentaje;

    public EstadisticaEmpleadoDTO(Integer empleadoId, String nombre, Double valor, Double porcentaje) {
        this.empleadoId = empleadoId;
        this.nombre = nombre;
        this.valor = valor;
        this.porcentaje = porcentaje;
    }

    public Integer getEmpleadoId() { return empleadoId; }
    public String getNombre() { return nombre; }
    public Double getValor() { return valor; }
    public Double getPorcentaje() { return porcentaje; }
}