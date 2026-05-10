package com.citaria.dto;

/**
 * DTO de skills de skill de empleado.
 */
public class EmpleadoSkillDTO {

    private Integer empleadoId;
    private Integer skillId;
    private String nombreSkill;

    public Integer getEmpleadoId() { return empleadoId; }
    public void setEmpleadoId(Integer empleadoId) { this.empleadoId = empleadoId; }

    public Integer getSkillId() { return skillId; }
    public void setSkillId(Integer skillId) { this.skillId = skillId; }

    public String getNombreSkill() { return nombreSkill; }
    public void setNombreSkill(String nombreSkill) { this.nombreSkill = nombreSkill; }
}