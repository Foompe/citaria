package com.citaria.controller;

import com.citaria.dto.EstadisticaEmpleadoDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.EstadisticaServicioDTO;
import com.citaria.service.EstadisticaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

/**
 * Controlador REST para las estadísticas del negocio.
 * Todos los datos se filtran automáticamente por la organización del usuario autenticado.
 * Los parámetros desde/hasta permiten filtrar por rango de fechas para obtener
 * resúmenes anuales, trimestrales o mensuales según necesidad.
 */
@Tag(name = "Estadísticas", description = "Métricas de rendimiento de clientes, empleados y servicios")
@RestController
@RequestMapping("/api/estadisticas")
public class EstadisticaController {

    private final EstadisticaService estadisticaService;

    public EstadisticaController(EstadisticaService estadisticaService) {
        this.estadisticaService = estadisticaService;
    }

    // ===== CLIENTES =====

    @Operation(summary = "Clientes nuevos vs recurrentes por mes",
            description = "valor1=nuevos, valor2=recurrentes")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/clientes/nuevos-vs-recurrentes")
    public ResponseEntity<List<EstadisticaMesDTO>> clientesNuevosVsRecurrentes(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.clientesNuevosVsRecurrentes(desde, hasta));
    }

    @Operation(summary = "Fidelización de clientes por mes",
            description = "valor1=totalClientes, valor2=porcentajeQueRepiten")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/clientes/fidelizacion")
    public ResponseEntity<List<EstadisticaMesDTO>> fidelizacionClientes(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.fidelizacionClientes(desde, hasta));
    }

    // ===== EMPLEADOS =====

    @Operation(summary = "Reservas atendidas por empleado",
            description = "valor=totalReservas, porcentaje=tasaCancelacion")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/empleados/reservas")
    public ResponseEntity<List<EstadisticaEmpleadoDTO>> reservasPorEmpleado(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.reservasPorEmpleado(desde, hasta));
    }

    @Operation(summary = "Importe generado por empleado",
            description = "valor=importeTotal en euros, porcentaje=null")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/empleados/importe")
    public ResponseEntity<List<EstadisticaEmpleadoDTO>> importePorEmpleado(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.importePorEmpleado(desde, hasta));
    }

    @Operation(summary = "Reservas canceladas por empleado",
            description = "valor=totalCanceladas, porcentaje=tasaCancelacion")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/empleados/cancelaciones")
    public ResponseEntity<List<EstadisticaEmpleadoDTO>> cancelacionesPorEmpleado(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.cancelacionesPorEmpleado(desde, hasta));
    }

    // ===== SERVICIOS =====

    @Operation(summary = "Servicios más solicitados",
            description = "valor=totalReservas, porcentaje=null — ordenado de mayor a menor")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/servicios/mas-solicitados")
    public ResponseEntity<List<EstadisticaServicioDTO>> serviciosMasSolicitados(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.serviciosMasSolicitados(desde, hasta));
    }

    @Operation(summary = "Importe generado por servicio",
            description = "valor=importeTotal en euros, porcentaje=null")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/servicios/importe")
    public ResponseEntity<List<EstadisticaServicioDTO>> importePorServicio(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.importePorServicio(desde, hasta));
    }

    @Operation(summary = "Tasa de cancelación por servicio",
            description = "valor=totalCanceladas, porcentaje=tasaCancelacion")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estadística obtenida correctamente")
    })
    @GetMapping("/servicios/cancelaciones")
    public ResponseEntity<List<EstadisticaServicioDTO>> cancelacionesPorServicio(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return ResponseEntity.ok(estadisticaService.cancelacionesPorServicio(desde, hasta));
    }
}