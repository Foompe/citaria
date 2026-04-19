package com.citaria.controller;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.EstadoReserva;
import com.citaria.service.ReservaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Controlador REST para la gestión de reservas.
 * Incluye endpoints de líneas de detalle de cada reserva.
 * La organización se resuelve automáticamente desde el token JWT.
 */
@Tag(name = "Reservas", description = "Gestión de reservas y líneas de detalle")
@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    private final ReservaService reservaService;

    public ReservaController(ReservaService reservaService) {
        this.reservaService = reservaService;
    }

    // ===== RESERVA =====

    @Operation(summary = "Obtener todas las reservas de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping
    public ResponseEntity<List<ReservaDTO>> obtenerTodas() {
        return ResponseEntity.ok(reservaService.obtenerTodas());
    }

    @Operation(summary = "Obtener reservas de un cliente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/cliente/{clienteId}")
    public ResponseEntity<List<ReservaDTO>> obtenerPorCliente(@PathVariable Integer clienteId) {
        return ResponseEntity.ok(reservaService.obtenerPorCliente(clienteId));
    }

    @Operation(summary = "Obtener reservas por fecha")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/fecha/{fecha}")
    public ResponseEntity<List<ReservaDTO>> obtenerPorFecha(@PathVariable LocalDate fecha) {
        return ResponseEntity.ok(reservaService.obtenerPorFecha(fecha));
    }

    @Operation(summary = "Obtener reservas por estado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/estado/{estado}")
    public ResponseEntity<List<ReservaDTO>> obtenerPorEstado(@PathVariable EstadoReserva estado) {
        return ResponseEntity.ok(reservaService.obtenerPorEstado(estado));
    }

    @Operation(summary = "Obtener reserva por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Reserva encontrada"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @GetMapping("/{id}")
    public ResponseEntity<ReservaDTO> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(reservaService.obtenerPorId(id));
    }

    @Operation(summary = "Crear una nueva reserva para un cliente")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Reserva creada correctamente")
    })
    @PostMapping("/cliente/{clienteId}")
    public ResponseEntity<ReservaDTO> crear(@PathVariable Integer clienteId,
                                            @Valid @RequestBody ReservaDTO dto) {
        return ResponseEntity.status(201).body(reservaService.crear(clienteId, dto));
    }

    @Operation(summary = "Actualizar estado de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estado actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @PatchMapping("/{id}/estado/{estado}")
    public ResponseEntity<ReservaDTO> actualizarEstado(@PathVariable Integer id,
                                                       @PathVariable EstadoReserva estado) {
        return ResponseEntity.ok(reservaService.actualizarEstado(id, estado));
    }

    @Operation(summary = "Cancelar una reserva y todas sus líneas de detalle activas")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Reserva cancelada correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        reservaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }

    // ===== LÍNEAS DE DETALLE =====

    @Operation(summary = "Obtener detalles de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/{id}/detalles")
    public ResponseEntity<List<ReservaServicioDTO>> obtenerDetalles(@PathVariable Integer id) {
        return ResponseEntity.ok(reservaService.obtenerDetallesPorReserva(id));
    }

    @Operation(summary = "Agregar detalle a una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Detalle agregado correctamente")
    })
    @PostMapping("/{id}/detalles")
    public ResponseEntity<ReservaServicioDTO> agregarDetalle(@PathVariable Integer id,
                                                             @Valid @RequestBody ReservaServicioDTO dto) {
        return ResponseEntity.status(201).body(reservaService.agregarDetalle(id, dto));
    }

    @Operation(summary = "Cancelar una línea de detalle individual de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Detalle cancelado correctamente"),
            @ApiResponse(responseCode = "404", description = "Detalle no encontrado")
    })
    @DeleteMapping("/{id}/detalles/{detalleId}")
    public ResponseEntity<Void> eliminarDetalle(@PathVariable Integer id,
                                                @PathVariable Integer detalleId) {
        reservaService.eliminarDetalle(detalleId);
        return ResponseEntity.noContent().build();
    }
}