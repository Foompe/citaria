package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.util.Objects;

/**
 * Tabla intermedia para representar la habilidad del empleado
 */
@Entity
@Table(name = "empleado_skill")
public class EmpleadoHabilidad {

    @EmbeddedId
    private EmpleadoHabilidadId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("empleadoId")
    @JoinColumn(name = "empleado_id", nullable = false)
    private Empleado empleado;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("habilidadId")
    @JoinColumn(name = "skill_id", nullable = false)
    private Habilidad habilidad;

    public EmpleadoHabilidad() {
    }

    public EmpleadoHabilidad(Empleado empleado, Habilidad habilidad) {
        this.empleado = empleado;
        this.habilidad = habilidad;
        this.id = new EmpleadoHabilidadId(empleado.getId(), habilidad.getId());
    }

    public EmpleadoHabilidadId getId() {
        return id;
    }

    public void setId(EmpleadoHabilidadId id) {
        this.id = id;
    }

    public Empleado getEmpleado() {
        return empleado;
    }

    public void setEmpleado(Empleado empleado) {
        this.empleado = empleado;
    }

    public Habilidad getHabilidad() {
        return habilidad;
    }

    public void setHabilidad(Habilidad habilidad) {
        this.habilidad = habilidad;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof EmpleadoHabilidad that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(empleado, that.empleado) && Objects.equals(habilidad, that.habilidad);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, empleado, habilidad);
    }

    @Override
    public String toString() {
        return "EmpleadoHabilidad{" +
                "empleadoId=" + (empleado != null ? empleado.getId() : null) +
                ", habilidadId=" + (habilidad != null ? habilidad.getId() : null) +
                '}';
    }
}