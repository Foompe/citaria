package com.citaria.dto;

import java.time.LocalDate;

/**
 * DTO para la transferencia de datos de un cierre puntual de una organización.
 */
public class OrganizacionHorarioCierreDTO {

    private Integer id;
    private Integer organizacionId;
    private LocalDate fecha;
    private String motivo;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getOrganizacionId() {
        return organizacionId;
    }

    public void setOrganizacionId(Integer organizacionId) {
        this.organizacionId = organizacionId;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }
}