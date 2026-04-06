package com.citaria.service;

import com.citaria.dto.ChatbotDTO;

/**
 * Contrato del servicio del chatbot.
 */
public interface ChatbotService {

    /**
     * Procesa la pregunta del usuario y devuelve la respuesta generada por Gemini.
     *
     * @param organizacionId id de la organización para construir el contexto
     * @param dto            DTO con la pregunta del usuario
     * @return DTO con la respuesta generada
     */
    ChatbotDTO preguntar(Integer organizacionId, ChatbotDTO dto);
}