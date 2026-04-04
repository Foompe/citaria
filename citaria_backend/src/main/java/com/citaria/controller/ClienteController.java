package com.citaria.controller;

import com.citaria.dto.ClienteDTO;
import com.citaria.service.ClienteService;
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
 * Controlador REST para la gestión de clientes.
 */
@Tag(name = "Clientes", description = "Gestión de clientes")
@RestController
@RequestMapping("/api/clientes")
public class ClienteController {

    private final ClienteService clienteService;

    @Autowired
    public ClienteController(ClienteService clienteService) {
        this.clienteService = clienteService;
    }

    @Operation(summary = "Obtener todos los clientes de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/organizacion/{organizacionId}")
    public ResponseEntity<List<ClienteDTO>> obtenerTodos(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(clienteService.obtenerTodos(organizacionId));
    }

    @Operation(summary = "Obtener cliente por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Cliente encontrado"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado")
    })
    @GetMapping("/{id}")
    public ResponseEntity<ClienteDTO> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(clienteService.obtenerPorId(id));
    }

    @Operation(summary = "Crear un nuevo cliente en una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Cliente creado correctamente")
    })
    @PostMapping("/organizacion/{organizacionId}")
    public ResponseEntity<ClienteDTO> crear(@PathVariable Integer organizacionId,
                                            @Valid @RequestBody ClienteDTO dto) {
        return ResponseEntity.status(201).body(clienteService.crear(organizacionId, dto));
    }

    @Operation(summary = "Actualizar un cliente existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Cliente actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado")
    })
    @PutMapping("/{id}")
    public ResponseEntity<ClienteDTO> actualizar(@PathVariable Integer id,
                                                 @Valid @RequestBody ClienteDTO dto) {
        return ResponseEntity.ok(clienteService.actualizar(id, dto));
    }

    @Operation(summary = "Eliminar un cliente")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Cliente eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        if (clienteService.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}