package com.citaria.controller;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;
import com.citaria.dto.ReservaDTO;
import com.citaria.service.EmpleadoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * Controlador REST para la gestión de empleados, sus horarios y skills.
 */
@Tag(name = "Empleados", description = "Gestión de empleados, horarios y skills")
@RestController
@RequestMapping("/api/empleados")
public class EmpleadoController {

    private final EmpleadoService empleadoService;

    @Autowired
    public EmpleadoController(EmpleadoService empleadoService) {
        this.empleadoService = empleadoService;
    }

    // EMPLEADO

    @Operation(summary = "Obtener todos los empleados de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping
    public ResponseEntity<List<EmpleadoDTO>> obtenerTodos() {
        return ResponseEntity.ok(empleadoService.obtenerTodos());
    }

    @Operation(summary = "Obtener empleado por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Empleado encontrado"),
            @ApiResponse(responseCode = "404", description = "Empleado no encontrado")
    })
    @GetMapping("/{id}")
    public ResponseEntity<EmpleadoDTO> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(empleadoService.obtenerPorId(id));
    }

    @Operation(summary = "Crear un nuevo empleado en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Empleado creado correctamente")
    })
    @PostMapping
    public ResponseEntity<EmpleadoDTO> crear(@Valid @RequestBody EmpleadoDTO dto) {
        return ResponseEntity.status(201).body(empleadoService.crear(dto));
    }

    @Operation(summary = "Actualizar un empleado existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Empleado actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Empleado no encontrado")
    })
    @PutMapping("/{id}")
    public ResponseEntity<EmpleadoDTO> actualizar(@PathVariable Integer id, @Valid @RequestBody EmpleadoDTO dto) {
        return ResponseEntity.ok(empleadoService.actualizar(id, dto));
    }

    @Operation(summary = "Subir foto de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Imagen subida correctamente"),
            @ApiResponse(responseCode = "404", description = "Empleado no encontrado"),
            @ApiResponse(responseCode = "502", description = "Error al subir la imagen")
    })
    @PostMapping("/{id}/imagen")
    public ResponseEntity<Void> subirFotoEmpleado(@PathVariable Integer id, @RequestParam MultipartFile archivo) {
        empleadoService.subirFotoEmpleado(id, archivo);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Obtener reservas futuras activas de un empleado",
            description = "Devuelve reservas en estado pendiente o confirmada. " +
                    "Debe consultarse antes de dar de baja al empleado para gestionar la reasignación.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente"),
            @ApiResponse(responseCode = "404", description = "Empleado no encontrado")
    })
    @GetMapping("/{id}/reservas-activas")
    public ResponseEntity<List<ReservaDTO>> obtenerReservasActivas(@PathVariable Integer id) {
        return ResponseEntity.ok(empleadoService.obtenerReservasActivas(id));
    }

    // HORARIOS

    @Operation(summary = "Obtener horarios de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista de horarios obtenida correctamente")
    })
    @GetMapping("/{id}/horarios")
    public ResponseEntity<List<HorarioEmpleadoDTO>> obtenerHorarios(@PathVariable Integer id) {
        return ResponseEntity.ok(empleadoService.obtenerHorariosPorEmpleado(id));
    }

    @Operation(summary = "Crear horario para un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Horario creado correctamente")
    })
    @PostMapping("/{id}/horarios")
    public ResponseEntity<HorarioEmpleadoDTO> crearHorario(@PathVariable Integer id,
                                                           @Valid @RequestBody HorarioEmpleadoDTO dto) {
        return ResponseEntity.status(201).body(empleadoService.crearHorario(id, dto));
    }

    @Operation(summary = "Actualizar horario de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Horario actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Horario no encontrado")
    })
    @PutMapping("/{id}/horarios/{horarioId}")
    public ResponseEntity<HorarioEmpleadoDTO> actualizarHorario(@PathVariable Integer id,
                                                                @PathVariable Integer horarioId,
                                                                @Valid @RequestBody HorarioEmpleadoDTO dto) {
        return ResponseEntity.ok(empleadoService.actualizarHorario(id, horarioId, dto));
    }

    @Operation(summary = "Eliminar horario de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Horario eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Horario no encontrado")
    })
    @DeleteMapping("/{id}/horarios/{horarioId}")
    public ResponseEntity<Void> eliminarHorario(@PathVariable Integer id,
                                                @PathVariable Integer horarioId) {
        empleadoService.eliminarHorario(id, horarioId);
        return ResponseEntity.noContent().build();
    }

    // SKILLS

    @Operation(summary = "Obtener skills de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista de skills obtenida correctamente")
    })
    @GetMapping("/{id}/skills")
    public ResponseEntity<List<EmpleadoSkillDTO>> obtenerSkills(@PathVariable Integer id) {
        return ResponseEntity.ok(empleadoService.obtenerSkillsPorEmpleado(id));
    }

    @Operation(summary = "Asignar skill a un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Skill asignada correctamente")
    })
    @PostMapping("/{id}/skills/{skillId}")
    public ResponseEntity<EmpleadoSkillDTO> asignarSkill(@PathVariable Integer id, @PathVariable Integer skillId) {
        return ResponseEntity.status(201).body(empleadoService.asignarSkill(id, skillId));
    }

    @Operation(summary = "Eliminar skill de un empleado")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Skill eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @DeleteMapping("/{id}/skills/{skillId}")
    public ResponseEntity<Void> eliminarSkill(@PathVariable Integer id, @PathVariable Integer skillId) {
        empleadoService.eliminarSkill(id, skillId);
        return ResponseEntity.noContent().build();
    }
}