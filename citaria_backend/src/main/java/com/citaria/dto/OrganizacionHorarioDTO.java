package com.citaria.dto;

import jakarta.validation.constraints.*;
import java.time.LocalTime;

/**
 * DTO para la transferencia de datos del horario semanal de una organización.
 */
public class OrganizacionHorarioDTO {

    private Integer id;
    private Integer organizacionId;

    @NotNull(message = "El día de la semana es obligatorio")
    @Min(value = 1, message = "El día de la semana debe ser entre 1 y 7")
    @Max(value = 7, message = "El día de la semana debe ser entre 1 y 7")
    private Integer diaSemana;

    @NotNull(message = "La hora de apertura es obligatoria")
    private LocalTime horaApertura;

    @NotNull(message = "La hora de cierre es obligatoria")
    private LocalTime horaCierre;

    @NotNull(message = "El campo activo es obligatorio")
    private Boolean activo;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public Integer getDiaSemana() { return diaSemana; }
    public void setDiaSemana(Integer diaSemana) { this.diaSemana = diaSemana; }

    public LocalTime getHoraApertura() { return horaApertura; }
    public void setHoraApertura(LocalTime horaApertura) { this.horaApertura = horaApertura; }

    public LocalTime getHoraCierre() { return horaCierre; }
    public void setHoraCierre(LocalTime horaCierre) { this.horaCierre = horaCierre; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}