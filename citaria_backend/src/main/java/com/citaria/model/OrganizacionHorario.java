package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalTime;
import java.util.Objects;

/**
 * Horario por día de la organización.
 */
@Entity
@Table(name = "organizacion_horario",
        uniqueConstraints = @UniqueConstraint(columnNames = {"organizacion_id", "dia_semana"}))
public class OrganizacionHorario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @Column(name = "dia_semana", nullable = false)
    private Integer diaSemana;

    @Column(name = "hora_apertura", nullable = false)
    private LocalTime horaApertura;

    @Column(name = "hora_cierre", nullable = false)
    private LocalTime horaCierre;

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
        if (!(o instanceof OrganizacionHorario that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(organizacion, that.organizacion) && Objects.equals(diaSemana, that.diaSemana) && Objects.equals(horaApertura, that.horaApertura) && Objects.equals(horaCierre, that.horaCierre) && Objects.equals(activo, that.activo);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, organizacion, diaSemana, horaApertura, horaCierre, activo);
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