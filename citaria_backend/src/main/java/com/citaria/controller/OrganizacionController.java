package com.citaria.controller;

import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.service.OrganizacionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de organizaciones.
 * Incluye endpoints de horarios, cierres y configuración visual.
 */
@Tag(name = "Organizaciones", description = "Gestión de organizaciones, horarios, cierres y configuración visual")
@RestController
@RequestMapping("/api/organizaciones")
public class OrganizacionController {

    private final OrganizacionService organizacionService;

    @Autowired
    public OrganizacionController(OrganizacionService organizacionService) {
        this.organizacionService = organizacionService;
    }

    // ===== ORGANIZACIÓN =====

    @Operation(summary = "Obtener todas las organizaciones")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping
    public ResponseEntity<List<OrganizacionDTO>> obtenerTodas() {
        return ResponseEntity.ok(organizacionService.obtenerTodas());
    }

    @Operation(summary = "Obtener organización por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Organización encontrada"),
            @ApiResponse(responseCode = "404", description = "Organización no encontrada")
    })
    @GetMapping("/{id}")
    public ResponseEntity<OrganizacionDTO> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(organizacionService.obtenerPorId(id));
    }

    @Operation(summary = "Crear una nueva organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Organización creada correctamente")
    })
    @PostMapping
    public ResponseEntity<OrganizacionDTO> crear(@Valid @RequestBody OrganizacionDTO dto) {
        return ResponseEntity.status(201).body(organizacionService.crear(dto));
    }

    @Operation(summary = "Actualizar una organización existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Organización actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Organización no encontrada")
    })
    @PutMapping("/{id}")
    public ResponseEntity<OrganizacionDTO> actualizar(@PathVariable Integer id,
                                                      @Valid @RequestBody OrganizacionDTO dto) {
        return ResponseEntity.ok(organizacionService.actualizar(id, dto));
    }

    @Operation(summary = "Eliminar una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Organización eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Organización no encontrada")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        if (organizacionService.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ===== CONFIGURACIÓN VISUAL =====

    @Operation(summary = "Obtener configuración visual de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Configuración encontrada"),
            @ApiResponse(responseCode = "404", description = "Configuración no encontrada")
    })
    @GetMapping("/{id}/configuracion")
    public ResponseEntity<ConfiguracionVisualDTO> obtenerConfiguracion(@PathVariable Integer id) {
        return ResponseEntity.ok(organizacionService.obtenerConfiguracionPorOrganizacion(id));
    }

    @Operation(summary = "Crear configuración visual de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Configuración creada correctamente")
    })
    @PostMapping("/{id}/configuracion")
    public ResponseEntity<ConfiguracionVisualDTO> crearConfiguracion(@PathVariable Integer id,
                                                                     @Valid @RequestBody ConfiguracionVisualDTO dto) {
        return ResponseEntity.status(201).body(organizacionService.crearConfiguracion(id, dto));
    }

    @Operation(summary = "Actualizar configuración visual de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Configuración actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Configuración no encontrada")
    })
    @PutMapping("/{id}/configuracion")
    public ResponseEntity<ConfiguracionVisualDTO> actualizarConfiguracion(@PathVariable Integer id,
                                                                          @Valid @RequestBody ConfiguracionVisualDTO dto) {
        return ResponseEntity.ok(organizacionService.actualizarConfiguracion(id, dto));
    }

    // ===== HORARIOS =====

    @Operation(summary = "Obtener horarios de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista de horarios obtenida correctamente")
    })
    @GetMapping("/{id}/horarios")
    public ResponseEntity<List<OrganizacionHorarioDTO>> obtenerHorarios(@PathVariable Integer id) {
        return ResponseEntity.ok(organizacionService.obtenerHorariosPorOrganizacion(id));
    }

    @Operation(summary = "Crear horario para una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Horario creado correctamente")
    })
    @PostMapping("/{id}/horarios")
    public ResponseEntity<OrganizacionHorarioDTO> crearHorario(@PathVariable Integer id,
                                                               @Valid @RequestBody OrganizacionHorarioDTO dto) {
        return ResponseEntity.status(201).body(organizacionService.crearHorario(id, dto));
    }

    @Operation(summary = "Actualizar horario de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Horario actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Horario no encontrado")
    })
    @PutMapping("/{id}/horarios/{horarioId}")
    public ResponseEntity<OrganizacionHorarioDTO> actualizarHorario(@PathVariable Integer id,
                                                                    @PathVariable Integer horarioId,
                                                                    @Valid @RequestBody OrganizacionHorarioDTO dto) {
        return ResponseEntity.ok(organizacionService.actualizarHorario(horarioId, dto));
    }

    @Operation(summary = "Eliminar horario de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Horario eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Horario no encontrado")
    })
    @DeleteMapping("/{id}/horarios/{horarioId}")
    public ResponseEntity<Void> eliminarHorario(@PathVariable Integer id,
                                                @PathVariable Integer horarioId) {
        if (organizacionService.eliminarHorario(horarioId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ===== CIERRES =====

    @Operation(summary = "Obtener cierres puntuales de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista de cierres obtenida correctamente")
    })
    @GetMapping("/{id}/cierres")
    public ResponseEntity<List<OrganizacionHorarioCierreDTO>> obtenerCierres(@PathVariable Integer id) {
        return ResponseEntity.ok(organizacionService.obtenerCierresPorOrganizacion(id));
    }

    @Operation(summary = "Crear cierre puntual para una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Cierre creado correctamente")
    })
    @PostMapping("/{id}/cierres")
    public ResponseEntity<OrganizacionHorarioCierreDTO> crearCierre(@PathVariable Integer id,
                                                                    @Valid @RequestBody OrganizacionHorarioCierreDTO dto) {
        return ResponseEntity.status(201).body(organizacionService.crearCierre(id, dto));
    }

    @Operation(summary = "Eliminar cierre puntual de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Cierre eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Cierre no encontrado")
    })
    @DeleteMapping("/{id}/cierres/{cierreId}")
    public ResponseEntity<Void> eliminarCierre(@PathVariable Integer id,
                                               @PathVariable Integer cierreId) {
        if (organizacionService.eliminarCierre(cierreId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}