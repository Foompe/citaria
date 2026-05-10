package com.citaria.controller;

import com.citaria.dto.DisponibilidadDTO;
import com.citaria.service.DisponibilidadService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;

/**
 * Controlador REST para la consulta de disponibilidad horaria.
 * Permite al cliente consultar las franjas disponibles.
 */
@Tag(name = "Disponibilidad", description = "Consulta de franjas horarias disponibles para reserva")
@RestController
@RequestMapping("/api/disponibilidad")
public class DisponibilidadController {

    private final DisponibilidadService disponibilidadService;

    @Autowired
    public DisponibilidadController(DisponibilidadService disponibilidadService) {
        this.disponibilidadService = disponibilidadService;
    }

    @Operation(summary = "Obtener franjas horarias disponibles",
            description = "Devuelve franjas de 15 minutos desde la apertura del negocio. " +
                    "empleadoId es opcional — si no se indica, evalúa todos los empleados válidos.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Disponibilidad calculada correctamente"),
            @ApiResponse(responseCode = "404", description = "Empleado no encontrado")
    })
    @GetMapping
    public ResponseEntity<DisponibilidadDTO> obtenerDisponibilidad(
            @RequestParam LocalDate fecha,
            @RequestParam List<Integer> servicioIds,
            @RequestParam(required = false) Integer empleadoId) {
        return ResponseEntity.ok(
                disponibilidadService.obtenerDisponibilidad(fecha, servicioIds, empleadoId));
    }
}