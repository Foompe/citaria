package com.citaria.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO para la comunicación con el chatbot.
 */
public class ChatbotDTO {

    @NotBlank(message = "La pregunta no puede estar vacía")
    private String pregunta;

    private String respuesta;

    public String getPregunta() { return pregunta; }
    public void setPregunta(String pregunta) { this.pregunta = pregunta; }

    public String getRespuesta() { return respuesta; }
    public void setRespuesta(String respuesta) { this.respuesta = respuesta; }
}