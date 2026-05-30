package com.citaria.dto;

/**
 * DTO de habilidades de habilidad de empleado.
 */
public class EmpleadoHabilidadDTO {

    private Integer empleadoId;
    private Integer habilidadId;
    private String nombreHabilidad;

    public Integer getEmpleadoId() { return empleadoId; }
    public void setEmpleadoId(Integer empleadoId) { this.empleadoId = empleadoId; }

    public Integer getHabilidadId() { return habilidadId; }
    public void setHabilidadId(Integer habilidadId) { this.habilidadId = habilidadId; }

    public String getNombreHabilidad() { return nombreHabilidad; }
    public void setNombreHabilidad(String nombreHabilidad) { this.nombreHabilidad = nombreHabilidad; }
}