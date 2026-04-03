package com.citaria.modelo;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;

/**
 * Cliente de una organización.
 * Puede existir con o sin cuenta de acceso — las credenciales son opcionales.
 * Incluye campo anonimizado_at para cumplimiento RGPD.
 */
@Entity
@Table(name = "cliente")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizacion_id", nullable = false)
    private Organizacion organizacion;

    @NotBlank
    @Size(max = 100)
    @Column(nullable = false, length = 100)
    private String nombre;

    @Size(max = 150)
    @Column(length = 150)
    private String apellidos;

    @Size(max = 9)
    @Column(length = 9)
    private String dni;

    @Email
    @Size(max = 255)
    @Column(length = 255)
    private String email;

    @Size(max = 20)
    @Column(length = 20)
    private String telefono;

    @Column(columnDefinition = "TEXT")
    private String notas;

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

    public
    LocalDateTime getAnonimizadoAt() {
        return anonimizadoAt;
    }

    public void setAnonimizadoAt(LocalDateTime anonimizadoAt) {
        this.anonimizadoAt = anonimizadoAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Cliente that)) return false;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
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