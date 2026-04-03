package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

/**
 * Configuración visual asociada a una organización.
 * Relación 1:1 con Organizacion — cada organización tiene exactamente una configuración visual.
 */
@Entity
@Table(name = "configuracion_visual")
public class ConfiguracionVisual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false, unique = true)
    private Organizacion organizacion;

    @Size(max = 500)
    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Size(max = 500)
    @Column(name = "favicon_url", length = 500)
    private String faviconUrl;

    @Size(max = 500)
    @Column(name = "icono_app_url", length = 500)
    private String iconoAppUrl;

    @Size(max = 7)
    @Column(name = "color_primario", length = 7)
    private String colorPrimario;

    @Size(max = 7)
    @Column(name = "color_secundario", length = 7)
    private String colorSecundario;

    @Size(max = 100)
    @Column(length = 100)
    private String tipografia;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Organizacion getOrganizacion() {
        return organizacion;
    }

    public void setOrganizacion(Organizacion organizacion) {
        this.organizacion = organizacion;
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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ConfiguracionVisual that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    @Override
    public String toString() {
        return "ConfiguracionVisual{" +
                "id=" + id +
                ", organizacionId=" + (organizacion != null ? organizacion.getId() : null) +
                ", colorPrimario='" + colorPrimario + '\'' +
                ", colorSecundario='" + colorSecundario + '\'' +
                ", tipografia='" + tipografia + '\'' +
                '}';
    }
}