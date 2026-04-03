package com.citaria.model;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;

/**
 * Clave primaria compuesta para EmpleadoSkill.
 */
@Embeddable
public class EmpleadoSkillId implements Serializable {

    private Integer empleadoId;
    private Integer skillId;

    public EmpleadoSkillId() {
    }

    public EmpleadoSkillId(Integer empleadoId, Integer skillId) {
        this.empleadoId = empleadoId;
        this.skillId = skillId;
    }

    public Integer getEmpleadoId() {
        return empleadoId;
    }

    public void setEmpleadoId(Integer empleadoId) {
        this.empleadoId = empleadoId;
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
        if (!(o instanceof EmpleadoSkillId that)) return false;
        return Objects.equals(empleadoId, that.empleadoId) &&
                Objects.equals(skillId, that.skillId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(empleadoId, skillId);
    }
}