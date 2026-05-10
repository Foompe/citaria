package com.citaria.service;

import com.citaria.dto.ChatbotDTO;

/**
 * Servicio del chatbot.
 */
public interface ChatbotService {

    /**
     * Procesa la pregunta del usuario y devuelve la respuesta generada por Gemini.
     *
     * @param dto DTO con la pregunta del usuario
     * @return DTO con la respuesta generada
     */
    ChatbotDTO preguntar(ChatbotDTO dto);
}
