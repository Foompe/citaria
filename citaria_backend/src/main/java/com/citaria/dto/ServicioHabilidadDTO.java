package com.citaria.dto;

/**
 * DTO de habilidad de servicio.
 */
public class ServicioHabilidadDTO {

    private Integer servicioId;
    private Integer habilidadId;
    private String nombreHabilidad;

    public Integer getServicioId() { return servicioId; }
    public void setServicioId(Integer servicioId) { this.servicioId = servicioId; }

    public Integer getHabilidadId() { return habilidadId; }
    public void setHabilidadId(Integer habilidadId) { this.habilidadId = habilidadId; }

    public String getNombreHabilidad() { return nombreHabilidad; }
    public void setNombreHabilidad(String nombreHabilidad) { this.nombreHabilidad = nombreHabilidad; }
}