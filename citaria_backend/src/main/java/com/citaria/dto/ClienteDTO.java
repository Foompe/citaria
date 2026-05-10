package com.citaria.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * DTO de un cliente.
 */
public class ClienteDTO {

    private Integer id;
    private Integer organizacionId;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar los 100 caracteres")
    private String nombre;

    @Size(max = 150, message = "Los apellidos no pueden superar los 150 caracteres")
    private String apellidos;

    @Size(max = 9, message = "El DNI no puede superar los 9 caracteres")
    private String dni;

    @Email(message = "El email no tiene un formato válido")
    @Size(max = 255, message = "El email no puede superar los 255 caracteres")
    private String email;

    @Size(max = 20, message = "El teléfono no puede superar los 20 caracteres")
    private String telefono;

    private String notas;
    private String fotoUrl;
    private LocalDateTime anonimizadoAt;

    //Valor derivado calculado según si el cliente tiene un Usuario vinculado.
    private boolean tieneUsuario;

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

    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }

    public LocalDateTime getAnonimizadoAt() { return anonimizadoAt; }
    public void setAnonimizadoAt(LocalDateTime anonimizadoAt) { this.anonimizadoAt = anonimizadoAt; }

    public boolean isTieneUsuario() { return tieneUsuario; }
    public void setTieneUsuario(boolean tieneUsuario) { this.tieneUsuario = tieneUsuario; }
}
