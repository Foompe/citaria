package com.citaria.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

/**
 * Relación N:M entre Empleado y Skill.
 * Representa las habilidades disponibles de un empleado.
 */
@Entity
@Table(name = "empleado_skill")
public class EmpleadoSkill {

    @EmbeddedId
    private EmpleadoSkillId id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("empleadoId")
    @JoinColumn(name = "empleado_id", nullable = false)
    private Empleado empleado;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("skillId")
    @JoinColumn(name = "skill_id", nullable = false)
    private Skill skill;

    public EmpleadoSkill() {
    }

    public EmpleadoSkill(Empleado empleado, Skill skill) {
        this.empleado = empleado;
        this.skill = skill;
        this.id = new EmpleadoSkillId(empleado.getId(), skill.getId());
    }

    public EmpleadoSkillId getId() {
        return id;
    }

    public void setId(EmpleadoSkillId id) {
        this.id = id;
    }

    public Empleado getEmpleado() {
        return empleado;
    }

    public void setEmpleado(Empleado empleado) {
        this.empleado = empleado;
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
        if (!(o instanceof EmpleadoSkill that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    @Override
    public String toString() {
        return "EmpleadoSkill{" +
                "empleadoId=" + (empleado != null ? empleado.getId() : null) +
                ", skillId=" + (skill != null ? skill.getId() : null) +
                '}';
    }
}