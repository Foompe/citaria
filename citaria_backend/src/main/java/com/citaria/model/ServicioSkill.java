package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.util.Objects;

/**
 * Tabla intermedia que representa las skills necesarias para dar un servicio concreto.
 */
@Entity
@Table(name = "servicio_skill")
public class ServicioSkill {

    @EmbeddedId
    private ServicioSkillId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("servicioId")
    @JoinColumn(name = "servicio_id", nullable = false)
    private Servicio servicio;

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
        if (!(o instanceof ServicioSkill that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(servicio, that.servicio) && Objects.equals(skill, that.skill);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, servicio, skill);
    }

    @Override
    public String toString() {
        return "ServicioSkill{" +
                "servicioId=" + (servicio != null ? servicio.getId() : null) +
                ", skillId=" + (skill != null ? skill.getId() : null) +
                '}';
    }
}