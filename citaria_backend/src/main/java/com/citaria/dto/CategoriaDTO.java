package com.citaria.dto;

import jakarta.validation.constraints.*;

/**
 * DTO para la transferencia de datos de una categoría.
 */
public class CategoriaDTO {

    private Integer id;
    private Integer organizacionId;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar los 100 caracteres")
    private String nombre;

    private Boolean activo;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}