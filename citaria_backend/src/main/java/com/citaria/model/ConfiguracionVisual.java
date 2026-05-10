package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.util.Objects;

/**
 * Configuración visual de una organización.
 */
@Entity
@Table(name = "configuracion_visual")
public class ConfiguracionVisual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false, unique = true)
    private Organizacion organizacion;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Column(name = "favicon_url", length = 500)
    private String faviconUrl;

    @Column(name = "icono_app_url", length = 500)
    private String iconoAppUrl;

    @Column(name = "color_primario", length = 7)
    private String colorPrimario;

    @Column(name = "color_secundario", length = 7)
    private String colorSecundario;

    @Column(length = 100)
    private String tipografia;

    //Para avisar al front de que debe actualizar
    @Version
    @Column(nullable = false)
    private Integer version = 0;

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

    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ConfiguracionVisual that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(organizacion, that.organizacion) && Objects.equals(logoUrl, that.logoUrl) && Objects.equals(faviconUrl, that.faviconUrl) && Objects.equals(iconoAppUrl, that.iconoAppUrl) && Objects.equals(colorPrimario, that.colorPrimario) && Objects.equals(colorSecundario, that.colorSecundario) && Objects.equals(tipografia, that.tipografia) && Objects.equals(version, that.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, organizacion, logoUrl, faviconUrl, iconoAppUrl, colorPrimario, colorSecundario, tipografia, version);
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