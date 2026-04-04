package com.citaria.controller;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.EstadoReserva;
import com.citaria.service.ReservaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Controlador REST para la gestión de reservas.
 * Incluye endpoints de líneas de detalle de cada reserva.
 */
@Tag(name = "Reservas", description = "Gestión de reservas y líneas de detalle")
@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    private ReservaService reservaService;

    @Autowired
    public ReservaController(ReservaService reservaService) {
        this.reservaService = reservaService;
    }

    // ===== RESERVA =====

    @Operation(summary = "Obtener todas las reservas de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/organizacion/{organizacionId}")
    public ResponseEntity<List<ReservaDTO>> obtenerTodas(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(reservaService.obtenerTodas(organizacionId));
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
    @GetMapping("/organizacion/{organizacionId}/fecha/{fecha}")
    public ResponseEntity<List<ReservaDTO>> obtenerPorFecha(@PathVariable Integer organizacionId,
                                                            @PathVariable LocalDate fecha) {
        return ResponseEntity.ok(reservaService.obtenerPorFecha(organizacionId, fecha));
    }

    @Operation(summary = "Obtener reservas por estado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/organizacion/{organizacionId}/estado/{estado}")
    public ResponseEntity<List<ReservaDTO>> obtenerPorEstado(@PathVariable Integer organizacionId,
                                                             @PathVariable EstadoReserva estado) {
        return ResponseEntity.ok(reservaService.obtenerPorEstado(organizacionId, estado));
    }

    @Operation(summary = "Obtener reserva por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Reserva encontrada"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @GetMapping("/{id}")
    public ResponseEntity<ReservaDTO> obtenerPorId(@PathVariable Integer id) {
        Optional<ReservaDTO> resultado = reservaService.obtenerPorId(id);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Crear una nueva reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Reserva creada correctamente")
    })
    @PostMapping("/organizacion/{organizacionId}/cliente/{clienteId}")
    public ResponseEntity<ReservaDTO> crear(@PathVariable Integer organizacionId,
                                            @PathVariable Integer clienteId,
                                            @RequestBody ReservaDTO dto) {
        return ResponseEntity.status(201).body(reservaService.crear(organizacionId, clienteId, dto));
    }

    @Operation(summary = "Actualizar estado de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estado actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @PatchMapping("/{id}/estado/{estado}")
    public ResponseEntity<ReservaDTO> actualizarEstado(@PathVariable Integer id,
                                                       @PathVariable EstadoReserva estado) {
        Optional<ReservaDTO> resultado = reservaService.actualizarEstado(id, estado);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Eliminar una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Reserva eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        if (reservaService.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
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
                                                             @RequestBody ReservaServicioDTO dto) {
        return ResponseEntity.status(201).body(reservaService.agregarDetalle(id, dto));
    }

    @Operation(summary = "Eliminar detalle de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Detalle eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Detalle no encontrado")
    })
    @DeleteMapping("/{id}/detalles/{detalleId}")
    public ResponseEntity<Void> eliminarDetalle(@PathVariable Integer id,
                                                @PathVariable Integer detalleId) {
        if (reservaService.eliminarDetalle(detalleId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}