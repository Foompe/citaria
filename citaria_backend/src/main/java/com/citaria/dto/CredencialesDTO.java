package com.citaria.dto;

import java.time.LocalDateTime;

/**
 * DTO para la transferencia de datos de las credenciales de un cliente.
 * La contraseña nunca se devuelve en la respuesta — solo se recibe para registro o cambio.
 */
public class CredencialesDTO {

    private Integer id;
    private Integer clienteId;
    private String email;
    private String password;
    private Boolean emailVerificado;
    private LocalDateTime ultimoAcceso;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getClienteId() { return clienteId; }
    public void setClienteId(Integer clienteId) { this.clienteId = clienteId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Boolean getEmailVerificado() { return emailVerificado; }
    public void setEmailVerificado(Boolean emailVerificado) { this.emailVerificado = emailVerificado; }

    public LocalDateTime getUltimoAcceso() { return ultimoAcceso; }
    public void setUltimoAcceso(LocalDateTime ultimoAcceso) { this.ultimoAcceso = ultimoAcceso; }
}