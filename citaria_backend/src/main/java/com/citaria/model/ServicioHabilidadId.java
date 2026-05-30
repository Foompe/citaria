package com.citaria.model;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clave primaria de la tabla intermedia entre servicio y habilidad
 */
@Embeddable
public class ServicioHabilidadId implements Serializable {

    private Integer servicioId;
    private Integer habilidadId;

    public ServicioHabilidadId() {
    }

    public ServicioHabilidadId(Integer servicioId, Integer habilidadId) {
        this.servicioId = servicioId;
        this.habilidadId = habilidadId;
    }

    public Integer getServicioId() {
        return servicioId;
    }

    public void setServicioId(Integer servicioId) {
        this.servicioId = servicioId;
    }

    public Integer getHabilidadId() {
        return habilidadId;
    }

    public void setHabilidadId(Integer habilidadId) {
        this.habilidadId = habilidadId;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ServicioHabilidadId that)) return false;
        return Objects.equals(servicioId, that.servicioId) && Objects.equals(habilidadId, that.habilidadId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(servicioId, habilidadId);
    }
}