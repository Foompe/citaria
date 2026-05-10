package com.citaria.dto;

/**
 * DTO de la configuración visual de una organización.
 */
public class ConfiguracionVisualDTO {

    private Integer id;
    private Integer organizacionId;
    private String logoUrl;
    private String faviconUrl;
    private String iconoAppUrl;
    private String colorPrimario;
    private String colorSecundario;
    private String tipografia;
    private Integer version;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getOrganizacionId() {
        return organizacionId;
    }

    public void setOrganizacionId(Integer organizacionId) {
        this.organizacionId = organizacionId;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getFaviconUrl() {
        return faviconUrl;
    }

    public void setFaviconUrl(String faviconUrl) {
        this.faviconUrl = faviconUrl;
    }

    public String getIconoAppUrl() {
        return iconoAppUrl;
    }

    public void setIconoAppUrl(String iconoAppUrl) {
        this.iconoAppUrl = iconoAppUrl;
    }

    public String getColorPrimario() {
        return colorPrimario;
    }

    public void setColorPrimario(String colorPrimario) {
        this.colorPrimario = colorPrimario;
    }

    public String getColorSecundario() {
        return colorSecundario;
    }

    public void setColorSecundario(String colorSecundario) {
        this.colorSecundario = colorSecundario;
    }

    public String getTipografia() {
        return tipografia;
    }

    public void setTipografia(String tipografia) {
        this.tipografia = tipografia;
    }

    public Integer getVersion() { return version; }

    public void setVersion(Integer version) { this.version = version; }
}