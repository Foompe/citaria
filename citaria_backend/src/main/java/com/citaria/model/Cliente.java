package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Cliente de una orgnaización sin cuenta en la app
 */
@Entity
@Table(name = "cliente")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(length = 150)
    private String apellidos;

    @Column(length = 9)
    private String dni;

    @Column(length = 255)
    private String email;

    @Column(length = 20)
    private String telefono;

    private String notas;

    @Column(name = "foto_url", length = 500)
    private String fotoUrl;

    @Column(name = "anonimizado_at")
    private LocalDateTime anonimizadoAt;

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

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }

    public String getFotoUrl() {
        return fotoUrl;
    }

    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }

    public LocalDateTime getAnonimizadoAt() {
        return anonimizadoAt;
    }

    public void setAnonimizadoAt(LocalDateTime anonimizadoAt) {
        this.anonimizadoAt = anonimizadoAt;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Cliente cliente)) return false;
        return Objects.equals(id, cliente.id) && Objects.equals(organizacion, cliente.organizacion) && Objects.equals(nombre, cliente.nombre) && Objects.equals(apellidos, cliente.apellidos) && Objects.equals(dni, cliente.dni) && Objects.equals(email, cliente.email) && Objects.equals(telefono, cliente.telefono) && Objects.equals(notas, cliente.notas) && Objects.equals(fotoUrl, cliente.fotoUrl) && Objects.equals(anonimizadoAt, cliente.anonimizadoAt);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, organizacion, nombre, apellidos, dni, email, telefono, notas, fotoUrl, anonimizadoAt);
    }

    @Override
    public String toString() {
        return "Cliente{" +
                "id=" + id +
                ", organizacionId=" + (organizacion != null ? organizacion.getId() : null) +
                ", nombre='" + nombre + '\'' +
                ", apellidos='" + apellidos + '\'' +
                ", email='" + email + '\'' +
                ", anonimizadoAt=" + anonimizadoAt +
                '}';
    }
}
