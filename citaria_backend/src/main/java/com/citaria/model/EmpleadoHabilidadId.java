package com.citaria.model;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clave primaria de la tabla intermedia de empleado con habilidad .
 */
@Embeddable
public class EmpleadoHabilidadId implements Serializable {

    private Integer empleadoId;
    private Integer habilidadId;

    public EmpleadoHabilidadId() {
    }

    public EmpleadoHabilidadId(Integer empleadoId, Integer habilidadId) {
        this.empleadoId = empleadoId;
        this.habilidadId = habilidadId;
    }

    public Integer getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(Integer empleadoId) {
        this.empleadoId = empleadoId;
    }

    public Integer getHabilidadId() {
        return habilidadId;
    }

    public void setHabilidadId(Integer habilidadId) {
        this.habilidadId = habilidadId;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof EmpleadoHabilidadId that)) return false;
        return Objects.equals(empleadoId, that.empleadoId) && Objects.equals(habilidadId, that.habilidadId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(empleadoId, habilidadId);
    }
}