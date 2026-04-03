package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalTime;

/**
 * Horario semanal de una organización.
 * Cada registro representa un día de la semana con su franja horaria.
 * El día se representa con un valor numérico del 1 (lunes) al 7 (domingo).
 */
@Entity
@Table(name = "organizacion_horario",
        uniqueConstraints = @UniqueConstraint(columnNames = {"organizacion_id", "dia_semana"}))
public class OrganizacionHorario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @NotNull
    @Min(1)
    @Max(7)
    @Column(name = "dia_semana", nullable = false, columnDefinition = "TINYINT")
    private Integer diaSemana;

    @NotNull
    @Column(name = "hora_apertura", nullable = false)
    private LocalTime horaApertura;

    @NotNull
    @Column(name = "hora_cierre", nullable = false)
    private LocalTime horaCierre;

    @NotNull
    @Column(nullable = false)
    private Boolean activo = true;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Organizacion getOrganizacion() {
        return organizacion;
    }

    public void setOrganizacion(Organizacion organizacion) {
        this.organizacion = organizacion;
    }

    public Integer getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(Integer diaSemana) {
        this.diaSemana = diaSemana;
    }

    public LocalTime getHoraApertura() {
        return horaApertura;
    }

    public void setHoraApertura(LocalTime horaApertura) {
        this.horaApertura = horaApertura;
    }

    public LocalTime getHoraCierre() {
        return horaCierre;
    }

    public void setHoraCierre(LocalTime horaCierre) {
        this.horaCierre = horaCierre;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof OrganizacionHorario that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    @Override
    public String toString() {
        return "OrganizacionHorario{" +
                "id=" + id +
                ", organizacionId=" + (organizacion != null ? organizacion.getId() : null) +
                ", diaSemana=" + diaSemana +
                ", horaApertura=" + horaApertura +
                ", horaCierre=" + horaCierre +
                ", activo=" + activo +
                '}';
    }
}