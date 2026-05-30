package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.util.Objects;

/**
 * Tabla intermedia que representa las habilidades necesarias para dar un servicio concreto.
 */
@Entity
@Table(name = "servicio_skill")
public class ServicioHabilidad {

    @EmbeddedId
    private ServicioHabilidadId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("servicioId")
    @JoinColumn(name = "servicio_id", nullable = false)
    private Servicio servicio;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("habilidadId")
    @JoinColumn(name = "skill_id", nullable = false)
    private Habilidad habilidad;

    public ServicioHabilidad() {
    }

    public ServicioHabilidad(Servicio servicio, Habilidad habilidad) {
        this.servicio = servicio;
        this.habilidad = habilidad;
        this.id = new ServicioHabilidadId(servicio.getId(), habilidad.getId());
    }

    public ServicioHabilidadId getId() {
        return id;
    }

    public void setId(ServicioHabilidadId id) {
        this.id = id;
    }

    public Servicio getServicio() {
        return servicio;
    }

    public void setServicio(Servicio servicio) {
        this.servicio = servicio;
    }

    public Habilidad getHabilidad() {
        return habilidad;
    }

    public void setHabilidad(Habilidad habilidad) {
        this.habilidad = habilidad;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ServicioHabilidad that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(servicio, that.servicio) && Objects.equals(habilidad, that.habilidad);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, servicio, habilidad);
    }

    @Override
    public String toString() {
        return "ServicioHabilidad{" +
                "servicioId=" + (servicio != null ? servicio.getId() : null) +
                ", habilidadId=" + (habilidad != null ? habilidad.getId() : null) +
                '}';
    }
}