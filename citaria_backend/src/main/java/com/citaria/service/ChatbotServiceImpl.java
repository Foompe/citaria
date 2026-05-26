package com.citaria.service;

import com.citaria.dto.ChatbotDTO;
import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import com.citaria.model.Servicio;
import com.citaria.repository.OrganizacionHorarioDAO;
import com.citaria.repository.ServicioDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Service
public class ChatbotServiceImpl implements ChatbotService {

    private static final String MENSAJE_FALLBACK_GEMINI =
            "Lo siento, no puedo responder en este momento. Por favor contacta directamente con nosotros.";
    private static final String CLAVE_CANDIDATES = "candidates";
    private static final String CLAVE_CONTENT = "content";
    private static final String CLAVE_CONTENTS = "contents";
    private static final String CLAVE_PARTS = "parts";
    private static final String CLAVE_TEXT = "text";
    private static final String CABECERA_CONTENT_TYPE = "Content-Type";
    private static final String MEDIA_TYPE_JSON = "application/json";
    private static final String[] DIAS_SEMANA = {
            "", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
    };
    private static final ParameterizedTypeReference<Map<String, Object>> TIPO_RESPUESTA_GEMINI =
            new ParameterizedTypeReference<>() {
            };

    private final ServicioDAO servicioDAO;
    private final OrganizacionHorarioDAO organizacionHorarioDAO;
    private final ContextoSeguridad contextoSeguridad;
    private final RestClient restClient;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    @Autowired
    public ChatbotServiceImpl(ServicioDAO servicioDAO,
                              OrganizacionHorarioDAO organizacionHorarioDAO,
                              ContextoSeguridad contextoSeguridad,
                              RestClient.Builder restClientBuilder) {
        this.servicioDAO = servicioDAO;
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.contextoSeguridad = contextoSeguridad;
        this.restClient = restClientBuilder.build();
    }

    // CHATBOT

    @Override
    public ChatbotDTO preguntar(ChatbotDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        String contexto = construirContexto(organizacion);
        String prompt = contexto + "\n\nPregunta del cliente: " + dto.getPregunta();

        String respuesta = llamarGemini(prompt);
        dto.setRespuesta(respuesta);
        return dto;
    }

    // CONSTRUCCIÓN DE CONTEXTO

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
            for (OrganizacionHorario horario : horarios) {
                if (horario.getActivo()) {
                    contexto.append("- ").append(DIAS_SEMANA[horario.getDiaSemana()])
                            .append(": ").append(horario.getHoraApertura())
                            .append(" - ").append(horario.getHoraCierre()).append("\n");
                }
            }
        }

        return contexto.toString();
    }

    // LLAMADA A GEMINI

    @SuppressWarnings("unchecked")
    private String llamarGemini(String prompt) {
        Map<String, Object> texto = Map.of(CLAVE_TEXT, prompt);
        List<Map<String, Object>> parts = List.of(texto);
        Map<String, Object> content = Map.of(CLAVE_PARTS, parts);
        List<Map<String, Object>> contents = List.of(content);
        Map<String, Object> cuerpo = Map.of(CLAVE_CONTENTS, contents);

        try {
            Map<String, Object> respuesta = restClient.post()
                    .uri(apiUrl + "?key=" + apiKey)
                    .header(CABECERA_CONTENT_TYPE, MEDIA_TYPE_JSON)
                    .body(cuerpo)
                    .retrieve()
                    .body(TIPO_RESPUESTA_GEMINI);

            if (respuesta == null) {
                return MENSAJE_FALLBACK_GEMINI;
            }

            if (!(respuesta.get(CLAVE_CANDIDATES) instanceof List)) {
                return MENSAJE_FALLBACK_GEMINI;
            }
            List<Map<String, Object>> candidates =
                    (List<Map<String, Object>>) respuesta.get(CLAVE_CANDIDATES);
            if (candidates.isEmpty()) {
                return MENSAJE_FALLBACK_GEMINI;
            }

            Map<String, Object> candidate = candidates.get(0);
            if (!(candidate.get(CLAVE_CONTENT) instanceof Map)) {
                return MENSAJE_FALLBACK_GEMINI;
            }
            Map<String, Object> responseContent =
                    (Map<String, Object>) candidate.get(CLAVE_CONTENT);

            if (!(responseContent.get(CLAVE_PARTS) instanceof List)) {
                return MENSAJE_FALLBACK_GEMINI;
            }
            List<Map<String, Object>> responseParts =
                    (List<Map<String, Object>>) responseContent.get(CLAVE_PARTS);
            if (responseParts.isEmpty()) {
                return MENSAJE_FALLBACK_GEMINI;
            }

            Map<String, Object> part = responseParts.get(0);
            if (!(part.get(CLAVE_TEXT) instanceof String)) {
                return MENSAJE_FALLBACK_GEMINI;
            }

            return (String) part.get(CLAVE_TEXT);

        } catch (Exception e) {
            return MENSAJE_FALLBACK_GEMINI;
        }
    }
}
