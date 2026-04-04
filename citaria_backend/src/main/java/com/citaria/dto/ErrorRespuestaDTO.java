package com.citaria.dto;

import java.time.LocalDateTime;

/**
 * DTO estándar para respuestas de error de la API.
 * Garantiza un formato consistente en todos los errores.
 */
public class ErrorRespuestaDTO {

    private int estado;
    private String mensaje;
    private LocalDateTime timestamp;

    public ErrorRespuestaDTO(int estado, String mensaje) {
        this.estado = estado;
        this.mensaje = mensaje;
        this.timestamp = LocalDateTime.now();
    }

    public int getEstado() { return estado; }
    public String getMensaje() { return mensaje; }
    public LocalDateTime getTimestamp() { return timestamp; }
}