package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalDate;
import java.util.Objects;

/**
 * Días que cierra la organización en el año
 */
@Entity
@Table(name = "organizacion_horario_cierre")
public class OrganizacionHorarioCierre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @Column(nullable = false)
    private LocalDate fecha;

    @Column(length = 100)
    private String motivo;

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

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof OrganizacionHorarioCierre that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(organizacion, that.organizacion) && Objects.equals(fecha, that.fecha) && Objects.equals(motivo, that.motivo);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, organizacion, fecha, motivo);
    }

    @Override
    public String toString() {
        return "OrganizacionHorarioCierre{" +
                "id=" + id +
                ", organizacionId=" + (organizacion != null ? organizacion.getId() : null) +
                ", fecha=" + fecha +
                ", motivo='" + motivo + '\'' +
                '}';
    }
}