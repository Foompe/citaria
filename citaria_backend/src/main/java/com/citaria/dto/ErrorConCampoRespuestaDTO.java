package com.citaria.dto;

import java.time.LocalDateTime;

/**
 * DTO de error para casos en los que el error está asociado a un campo concreto.
 */
public class ErrorConCampoRespuestaDTO {

    private int estado;
    private String mensaje;
    private String campo;
    private LocalDateTime timestamp;

    public ErrorConCampoRespuestaDTO(int estado, String mensaje, String campo) {
        this.estado = estado;
        this.mensaje = mensaje;
        this.campo = campo;
        this.timestamp = LocalDateTime.now();
    }

    public int getEstado() { return estado; }
    public String getMensaje() { return mensaje; }
    public String getCampo() { return campo; }
    public LocalDateTime getTimestamp() { return timestamp; }
}