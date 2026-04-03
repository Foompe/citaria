package com.citaria.model;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clave primaria compuesta para ServicioSkill.
 */
@Embeddable
public class ServicioSkillId implements Serializable {

    private Integer servicioId;
    private Integer skillId;

    public ServicioSkillId() {
    }

    public ServicioSkillId(Integer servicioId, Integer skillId) {
        this.servicioId = servicioId;
        this.skillId = skillId;
    }

    public Integer getServicioId() {
        return servicioId;
    }

    public void setServicioId(Integer servicioId) {
        this.servicioId = servicioId;
    }

    public Integer getSkillId() {
        return skillId;
    }

    public void setSkillId(Integer skillId) {
        this.skillId = skillId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ServicioSkillId that)) return false;
        return Objects.equals(servicioId, that.servicioId) &&
                Objects.equals(skillId, that.skillId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(servicioId, skillId);
    }
}