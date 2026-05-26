package com.citaria.controller;

import com.citaria.dto.ClienteDTO;
import com.citaria.service.ClienteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    @Operation(summary = "Obtener clientes paginados con búsqueda opcional",
            description = "Busca por nombre, apellidos, email o teléfono. Excluye anonimizados. Ordenado por nombre ASC.")
    @ApiResponse(responseCode = "200", description = "Página obtenida correctamente")
    @GetMapping("/admin")
    public ResponseEntity<Page<ClienteDTO>> obtenerPaginado(
            @RequestParam(required = false) String busqueda,
            @RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "20") int tamano) {
        return ResponseEntity.ok(clienteService.obtenerPaginado(busqueda, pagina, tamano));
    }

    @Operation(summary = "Buscar clientes por dni o email",
            description = "Solo se usa un parámetro a la vez. Devuelve lista vacía si no hay coincidencia.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/buscar")
    public ResponseEntity<List<ClienteDTO>> buscarClientes(
            @RequestParam(required = false) String dni,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String telefono) {
        return ResponseEntity.ok(clienteService.buscarClientes(dni, email, telefono));
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

    @Operation(summary = "Crear un nuevo cliente en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Cliente creado correctamente"),
            @ApiResponse(responseCode = "409", description = "Ya existe un cliente con ese email o DNI")
    })
    @PostMapping
    public ResponseEntity<ClienteDTO> crear(@Valid @RequestBody ClienteDTO dto) {
        return ResponseEntity.status(201).body(clienteService.crear(dto));
    }

    @Operation(summary = "Actualizar un cliente existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Cliente actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado"),
            @ApiResponse(responseCode = "409", description = "Ya existe un cliente con ese email o DNI")
    })
    @PutMapping("/{id}")
    public ResponseEntity<ClienteDTO> actualizar(@PathVariable Integer id,
                                                 @Valid @RequestBody ClienteDTO dto) {
        return ResponseEntity.ok(clienteService.actualizar(id, dto));
    }

    @Operation(summary = "Subir foto de un cliente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Imagen subida correctamente"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado"),
            @ApiResponse(responseCode = "502", description = "Error al subir la imagen")
    })
    @PostMapping("/{id}/imagen")
    public ResponseEntity<Void> subirFotoCliente(@PathVariable Integer id,
                                                 @RequestParam MultipartFile archivo) {
        clienteService.subirFotoCliente(id, archivo);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Dar de baja un cliente — anonimiza sus datos personales",
            description = "Si el cliente tiene cuenta de usuario, anonimiza también el usuario. Operación irreversible.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Cliente dado de baja correctamente"),
            @ApiResponse(responseCode = "404", description = "Cliente no encontrado")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> darDeBaja(@PathVariable Integer id) {
        clienteService.anonimizarCliente(id);
        return ResponseEntity.noContent().build();
    }
}
