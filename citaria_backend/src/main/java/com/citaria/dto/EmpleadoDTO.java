package com.citaria.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * DTO de datos de un empleado.
 */
public class EmpleadoDTO {

    private Integer id;
    private Integer organizacionId;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String nombre;

    @NotBlank(message = "Los apellidos son obligatorios")
    @Size(max = 100, message = "Los apellidos no pueden superar los 100 caracteres")
    private String apellidos;

    @Email(message = "El email no tiene un formato válido")
    @Size(max = 255, message = "El email no puede superar los 255 caracteres")
    private String email;

    @Size(min = 9, max = 15, message = "El teléfono debe tener entre 9 y 15 caracteres")
    private String telefono;

    @Size(max = 500, message = "La URL de la foto no puede superar los 500 caracteres")
    private String fotoUrl;

    private Boolean activo;
    private LocalDateTime anonimizadoAt;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }

    public LocalDateTime getAnonimizadoAt() { return anonimizadoAt; }
    public void setAnonimizadoAt(LocalDateTime anonimizadoAt) { this.anonimizadoAt = anonimizadoAt; }
}