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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;

/**
 * Controlador REST para la gestión de reservas y líneas de detalle.
 */
@Tag(name = "Reservas", description = "Gestión de reservas y líneas de detalle")
@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    private final ReservaService reservaService;

    @Autowired
    public ReservaController(ReservaService reservaService) {
        this.reservaService = reservaService;
    }

    // RESERVA

    @Operation(summary = "Obtener reservas por fecha y estados",
            description = "Filtra por fecha obligatoria y opcionalmente por uno o varios estados.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/filtros")
    public ResponseEntity<List<ReservaDTO>> obtenerConFiltros(
            @RequestParam LocalDate fecha,
            @RequestParam(required = false) List<EstadoReserva> estados) {
        return ResponseEntity.ok(reservaService.obtenerPorFechaYEstados(fecha, estados));
    }

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
    public ResponseEntity<ReservaDTO> crear(@PathVariable Integer clienteId, @Valid @RequestBody ReservaDTO dto) {
        return ResponseEntity.status(201).body(reservaService.crear(clienteId, dto));
    }

    @Operation(summary = "Actualizar estado de una reserva. Solo ADMIN.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estado actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @PatchMapping("/{id}/estado/{estado}")
    public ResponseEntity<ReservaDTO> actualizarEstado(@PathVariable Integer id, @PathVariable EstadoReserva estado) {
        return ResponseEntity.ok(reservaService.actualizarEstado(id, estado));
    }

    @Operation(summary = "Cancelar una reserva",
            description = "ADMIN puede cancelar cualquier reserva. ROLE_CLIENT solo las suyas en estado pendiente o confirmada.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Reserva cancelada correctamente"),
            @ApiResponse(responseCode = "404", description = "Reserva no encontrada")
    })
    @PatchMapping("/{id}/cancelar")
    public ResponseEntity<Void> cancelar(@PathVariable Integer id, @RequestParam(required = false) String motivo) {
        reservaService.cancelar(id, motivo);
        return ResponseEntity.noContent().build();
    }

    // LÍNEAS DE RESERVA

    @Operation(summary = "Obtener lineas de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/{id}/detalles")
    public ResponseEntity<List<ReservaServicioDTO>> obtenerDetalles(@PathVariable Integer id) {
        return ResponseEntity.ok(reservaService.obtenerLineasPorReserva(id));
    }

    @Operation(summary = "Agregar línea a una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Línea agregada correctamente")
    })
    @PostMapping("/{id}/detalles")
    public ResponseEntity<ReservaServicioDTO> agregarDetalle(@PathVariable Integer id,
                                                             @Valid @RequestBody ReservaServicioDTO dto) {
        return ResponseEntity.status(201).body(reservaService.agregarLineaAReserva(id, dto));
    }

    @Operation(summary = "Cancelar una línea de detalle individual de una reserva")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Línea cancelada correctamente"),
            @ApiResponse(responseCode = "404", description = "Línea no encontrado")
    })
    @DeleteMapping("/{id}/detalles/{detalleId}")
    public ResponseEntity<Void> eliminarDetalle(@PathVariable Integer id, @PathVariable Integer detalleId) {
        reservaService.eliminarLinea(id, detalleId);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Reasignar el empleado de una línea de detalle. Solo ADMIN.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Empleado reasignado correctamente"),
            @ApiResponse(responseCode = "404", description = "Línea o empleado no encontrado")
    })
    @PatchMapping("/{id}/detalles/{detalleId}/empleado/{empleadoId}")
    public ResponseEntity<ReservaServicioDTO> reasignarEmpleado(@PathVariable Integer id,
                                                                @PathVariable Integer detalleId,
                                                                @PathVariable Integer empleadoId) {
        return ResponseEntity.ok(reservaService.reasignarEmpleadoDetalle(id, detalleId, empleadoId));
    }
}