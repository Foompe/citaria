package com.citaria.dto;

/**
 * DTO de respuesta para el proceso de autenticación.
 * Encapsula el token JWT generado tras un login exitoso.
 */
public class LoginRespuestaDTO {

    private final String token;

    public LoginRespuestaDTO(String token) {
        this.token = token;
    }

    public String getToken() {
        return token;
    }
}