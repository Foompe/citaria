package com.citaria.dto;

import jakarta.validation.constraints.*;

/**
 * DTO de una organización.
 */
public class OrganizacionDTO {

    private Integer id;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 100, message = "El nombre no puede superar los 100 caracteres")
    private String nombre;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El email no tiene un formato válido")
    @Size(max = 255, message = "El email no puede superar los 255 caracteres")
    private String email;

    @Size(max = 20, message = "El teléfono no puede superar los 20 caracteres")
    private String telefono;

    @Size(max = 20, message = "El CIF no puede superar los 20 caracteres")
    private String cif;

    @Size(max = 255, message = "La calle no puede superar los 255 caracteres")
    private String calle;

    @Size(max = 10, message = "El código postal no puede superar los 10 caracteres")
    private String codigoPostal;

    @Size(max = 100, message = "La ciudad no puede superar los 100 caracteres")
    private String ciudad;

    @NotBlank(message = "El país es obligatorio")
    @Size(max = 2, message = "El país debe ser un código de 2 caracteres")
    private String pais;

    // Solo lectura — generado por el sistema, nunca enviado por el cliente
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
}