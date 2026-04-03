package com.citaria.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

/**
 * Festivos y cierres puntuales de una organización.
 * La combinación organizacion_id + fecha es única.
 */
@Entity
@Table(name = "organizacion_horario_cierre")
public class OrganizacionHorarioCierre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @NotNull
    @Column(nullable = false)
    private java.time.LocalDate fecha;

    @Size(max = 100)
    @Column(length = 100)
    private String motivo;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Organizacion getOrganizacion() { return organizacion; }
    public void setOrganizacion(Organizacion organizacion) { this.organizacion = organizacion; }

    public java.time.LocalDate getFecha() { return fecha; }
    public void setFecha(java.time.LocalDate fecha) { this.fecha = fecha; }

    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof OrganizacionHorarioCierre that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
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