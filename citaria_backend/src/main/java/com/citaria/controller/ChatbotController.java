package com.citaria.controller;

import com.citaria.dto.ChatbotDTO;
import com.citaria.service.ChatbotService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST para el chatbot de la organización.
 */
@Tag(name = "Chatbot", description = "Asistente virtual de la organización")
@RestController
@RequestMapping("/api/chatbot")
public class ChatbotController {

    private final ChatbotService chatbotService;

    @Autowired
    public ChatbotController(ChatbotService chatbotService) {
        this.chatbotService = chatbotService;
    }

    @Operation(summary = "Enviar pregunta al chatbot")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Respuesta generada correctamente"),
            @ApiResponse(responseCode = "400", description = "Pregunta vacía o inválida"),
            @ApiResponse(responseCode = "404", description = "Organización no encontrada")
    })
    @PostMapping
    public ResponseEntity<ChatbotDTO> preguntar(@Valid @RequestBody ChatbotDTO dto) {
        return ResponseEntity.ok(chatbotService.preguntar(dto));
    }
}