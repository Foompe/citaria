package com.citaria.dto;

import java.time.LocalDateTime;

/**
 * DTO para la transferencia de datos de un cliente.
 */
public class ClienteDTO {

    private Integer id;
    private Integer organizacionId;
    private String nombre;
    private String apellidos;
    private String dni;
    private String email;
    private String telefono;
    private String notas;
    private LocalDateTime anonimizadoAt;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }

    public LocalDateTime getAnonimizadoAt() { return anonimizadoAt; }
    public void setAnonimizadoAt(LocalDateTime anonimizadoAt) { this.anonimizadoAt = anonimizadoAt; }
}