package com.citaria.dto;

/**
 * DTO para la transferencia de datos de una categoría.
 */
public class CategoriaDTO {

    private Integer id;
    private Integer organizacionId;
    private String nombre;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}