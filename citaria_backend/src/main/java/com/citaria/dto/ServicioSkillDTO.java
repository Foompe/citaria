package com.citaria.dto;

/**
 * DTO para la transferencia de datos de la relación servicio-skill.
 */
public class ServicioSkillDTO {

    private Integer servicioId;
    private Integer skillId;
    private String nombreSkill;

    public Integer getServicioId() { return servicioId; }
    public void setServicioId(Integer servicioId) { this.servicioId = servicioId; }

    public Integer getSkillId() { return skillId; }
    public void setSkillId(Integer skillId) { this.skillId = skillId; }

    public String getNombreSkill() { return nombreSkill; }
    public void setNombreSkill(String nombreSkill) { this.nombreSkill = nombreSkill; }
}