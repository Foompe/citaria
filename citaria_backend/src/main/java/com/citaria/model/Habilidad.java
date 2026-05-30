package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.util.Objects;

/**
 * Habilidad que requiere un servicio y que un empleado debe tener para poder darlo.
 */
@Entity
@Table(name = "skill")
public class Habilidad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @Column(nullable = false, length = 100)
    private String nombre;

    private String descripcion;

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

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Habilidad habilidad)) return false;
        return Objects.equals(id, habilidad.id) && Objects.equals(organizacion, habilidad.organizacion) && Objects.equals(nombre, habilidad.nombre) && Objects.equals(descripcion, habilidad.descripcion) && Objects.equals(activo, habilidad.activo);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, organizacion, nombre, descripcion, activo);
    }

    @Override
    public String toString() {
        return "Habilidad{" +
                "id=" + id +
                ", organizacionId=" + (organizacion != null ? organizacion.getId() : null) +
                ", nombre='" + nombre + '\'' +
                ", descripcion='" + descripcion + '\'' +
                ", activo=" + activo +
                '}';
    }
}