package com.citaria.dto;

import jakarta.validation.constraints.*;

/**
 * DTO de entrada para el registro de un nuevo cliente.
 * El tokenRegistro identifica la organización de forma opaca — el cliente
 * lo obtiene del enlace o QR que le proporciona la empresa, sin necesidad
 * de conocer ningún identificador interno del sistema.
 */
public class RegistroRequestDTO {

    @NotBlank(message = "El token de registro es obligatorio")
    private String tokenRegistro;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El email no tiene un formato válido")
    private String email;

    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 8, message = "La contraseña debe tener al menos 8 caracteres")
    private String password;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar los 100 caracteres")
    private String nombre;

    @Size(max = 150, message = "Los apellidos no pueden superar los 150 caracteres")
    private String apellidos;

    @Size(max = 20, message = "El teléfono no puede superar los 20 caracteres")
    private String telefono;

    public String getTokenRegistro() { return tokenRegistro; }
    public void setTokenRegistro(String tokenRegistro) { this.tokenRegistro = tokenRegistro; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
}