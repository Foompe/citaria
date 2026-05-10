package com.citaria.dto;

/**
 * Proyección de solo lectura para el selector público de organizaciones.
 */
public class OrganizacionPublicaDTO {

    private Integer id;
    private String nombre;
    private String logoUrl;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }
}
