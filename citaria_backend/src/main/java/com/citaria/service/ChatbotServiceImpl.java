package com.citaria.service;

import com.citaria.dto.ChatbotDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import com.citaria.model.Servicio;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.OrganizacionHorarioDAO;
import com.citaria.repository.ServicioDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

/**
 * Implementación del servicio del chatbot.
 * Construye el contexto de la organización y llama a Gemini API.
 */
@Service
public class ChatbotServiceImpl implements ChatbotService {

    private final OrganizacionDAO organizacionDAO;
    private final ServicioDAO servicioDAO;
    private final OrganizacionHorarioDAO organizacionHorarioDAO;
    private final WebClient webClient;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    @Autowired
    public ChatbotServiceImpl(OrganizacionDAO organizacionDAO,
                              ServicioDAO servicioDAO,
                              OrganizacionHorarioDAO organizacionHorarioDAO,
                              WebClient.Builder webClientBuilder) {
        this.organizacionDAO = organizacionDAO;
        this.servicioDAO = servicioDAO;
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.webClient = webClientBuilder.build();
    }

    @Override
    public ChatbotDTO preguntar(Integer organizacionId, ChatbotDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));

        String contexto = construirContexto(organizacion);
        String prompt = contexto + "\n\nPregunta del cliente: " + dto.getPregunta();

        String respuesta = llamarGemini(prompt);
        dto.setRespuesta(respuesta);
        return dto;
    }

    private String construirContexto(Organizacion organizacion) {
        StringBuilder contexto = new StringBuilder();

        contexto.append("Eres el asistente virtual de ")
                .append(organizacion.getNombre())
                .append(". Responde de forma amable y concisa solo sobre los servicios, ")
                .append("precios y horarios de este negocio. ")
                .append("Si te preguntan algo que no está en la información proporcionada, ")
                .append("indica que no tienes esa información y sugiere contactar directamente.\n\n");

        contexto.append("Información del negocio:\n");
        contexto.append("Nombre: ").append(organizacion.getNombre()).append("\n");
        contexto.append("Email: ").append(organizacion.getEmail()).append("\n");

        if (organizacion.getTelefono() != null) {
            contexto.append("Teléfono: ").append(organizacion.getTelefono()).append("\n");
        }

        if (organizacion.getCiudad() != null) {
            contexto.append("Ciudad: ").append(organizacion.getCiudad()).append("\n");
        }

        List<Servicio> servicios = servicioDAO.findByOrganizacion(organizacion);
        if (!servicios.isEmpty()) {
            contexto.append("\nServicios disponibles:\n");
            for (Servicio servicio : servicios) {
                if (servicio.getActivo()) {
                    contexto.append("- ").append(servicio.getNombre())
                            .append(": ").append(servicio.getPrecio()).append("€")
                            .append(", duración: ").append(servicio.getDuracionMinutos()).append(" minutos");
                    if (servicio.getDescripcion() != null) {
                        contexto.append(", ").append(servicio.getDescripcion());
                    }
                    contexto.append("\n");
                }
            }
        }

        List<OrganizacionHorario> horarios = organizacionHorarioDAO.findByOrganizacion(organizacion);
        if (!horarios.isEmpty()) {
            contexto.append("\nHorarios:\n");
            String[] diasSemana = {"", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"};
            for (OrganizacionHorario horario : horarios) {
                if (horario.getActivo()) {
                    contexto.append("- ").append(diasSemana[horario.getDiaSemana()])
                            .append(": ").append(horario.getHoraApertura())
                            .append(" - ").append(horario.getHoraCierre()).append("\n");
                }
            }
        }

        return contexto.toString();
    }

    private String llamarGemini(String prompt) {
        Map<String, Object> cuerpo = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(
                                Map.of("text", prompt)
                        ))
                )
        );

        Map respuesta = webClient.post()
                .uri(apiUrl + "?key=" + apiKey)
                .header("Content-Type", "application/json")
                .bodyValue(cuerpo)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        try {
            List candidates = (List) respuesta.get("candidates");
            Map candidate = (Map) candidates.get(0);
            Map content = (Map) candidate.get("content");
            List parts = (List) content.get("parts");
            Map part = (Map) parts.get(0);
            return (String) part.get("text");
        } catch (Exception e) {
            return "Lo siento, no puedo responder en este momento. Por favor contacta directamente con nosotros.";
        }
    }
}