package com.citaria.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

/**
 * Relación N:M entre Servicio y Skill.
 * Representa las habilidades requeridas por un servicio.
 */
@Entity
@Table(name = "servicio_skill")
public class ServicioSkill {

    @EmbeddedId
    private ServicioSkillId id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("servicioId")
    @JoinColumn(name = "servicio_id", nullable = false)
    private Servicio servicio;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("skillId")
    @JoinColumn(name = "skill_id", nullable = false)
    private Skill skill;

    public ServicioSkill() {
    }

    public ServicioSkill(Servicio servicio, Skill skill) {
        this.servicio = servicio;
        this.skill = skill;
        this.id = new ServicioSkillId(servicio.getId(), skill.getId());
    }

    public ServicioSkillId getId() {
        return id;
    }

    public void setId(ServicioSkillId id) {
        this.id = id;
    }

    public Servicio getServicio() {
        return servicio;
    }

    public void setServicio(Servicio servicio) {
        this.servicio = servicio;
    }

    public Skill getSkill() {
        return skill;
    }

    public void setSkill(Skill skill) {
        this.skill = skill;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ServicioSkill that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    @Override
    public String toString() {
        return "ServicioSkill{" +
                "servicioId=" + (servicio != null ? servicio.getId() : null) +
                ", skillId=" + (skill != null ? skill.getId() : null) +
                '}';
    }
}