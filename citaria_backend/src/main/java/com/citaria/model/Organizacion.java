package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.util.Objects;

/**
 * Representa a cada empresa registrada .
 */
@Entity
@Table(name = "organizacion")
public class Organizacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(length = 20)
    private String telefono;

    @Column(unique = true, length = 20)
    private String cif;

    @Column(length = 255)
    private String calle;

    @Column(name = "codigo_postal", length = 10)
    private String codigoPostal;

    @Column(length = 100)
    private String ciudad;

    @Column(nullable = false, length = 2)
    private String pais;

    @Column(name = "token_registro", nullable = false, unique = true, length = 100)
    private String tokenRegistro;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getCif() { return cif; }
    public void setCif(String cif) { this.cif = cif; }

    public String getCalle() { return calle; }
    public void setCalle(String calle) { this.calle = calle; }

    public String getCodigoPostal() { return codigoPostal; }
    public void setCodigoPostal(String codigoPostal) { this.codigoPostal = codigoPostal; }

    public String getCiudad() { return ciudad; }
    public void setCiudad(String ciudad) { this.ciudad = ciudad; }

    public String getPais() { return pais; }
    public void setPais(String pais) { this.pais = pais; }

    public String getTokenRegistro() { return tokenRegistro; }
    public void setTokenRegistro(String tokenRegistro) { this.tokenRegistro = tokenRegistro; }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Organizacion that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(nombre, that.nombre) && Objects.equals(email, that.email) && Objects.equals(telefono, that.telefono) && Objects.equals(cif, that.cif) && Objects.equals(calle, that.calle) && Objects.equals(codigoPostal, that.codigoPostal) && Objects.equals(ciudad, that.ciudad) && Objects.equals(pais, that.pais) && Objects.equals(tokenRegistro, that.tokenRegistro);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, nombre, email, telefono, cif, calle, codigoPostal, ciudad, pais, tokenRegistro);
    }

    @Override
    public String toString() {
        return "Organizacion{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", email='" + email + '\'' +
                ", cif='" + cif + '\'' +
                ", ciudad='" + ciudad + '\'' +
                ", pais='" + pais + '\'' +
                '}';
    }
}