package com.citaria.dto;

/**
 * DTO de estadísticas agrupadas por empleado o servicio.
 * Reutilizable para múltiples métricas.
 */
public class EstadisticaItemDTO {

    private Integer id;
    private String nombre;
    private Double valor;
    private Double porcentaje;

    public EstadisticaItemDTO(Integer id, String nombre, Double valor, Double porcentaje) {
        this.id = id;
        this.nombre = nombre;
        this.valor = valor;
        this.porcentaje = porcentaje;
    }

    public Integer getId() { return id; }
    public String getNombre() { return nombre; }
    public Double getValor() { return valor; }
    public Double getPorcentaje() { return porcentaje; }
}