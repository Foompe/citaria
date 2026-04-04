package com.citaria.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

/**
 * DTO para la transferencia de datos de un cierre puntual de una organización.
 */
public class OrganizacionHorarioCierreDTO {

    private Integer id;
    private Integer organizacionId;

    @NotNull(message = "La fecha es obligatoria")
    private LocalDate fecha;

    @Size(max = 100, message = "El motivo no puede superar los 100 caracteres")
    private String motivo;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
}