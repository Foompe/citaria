package com.citaria.dto;

import java.time.LocalDateTime;

/**
 * DTO para la transferencia de datos de un empleado.
 */
public class EmpleadoDTO {

    private Integer id;
    private Integer organizacionId;
    private String nombre;
    private String apellidos;
    private String email;
    private String telefono;
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