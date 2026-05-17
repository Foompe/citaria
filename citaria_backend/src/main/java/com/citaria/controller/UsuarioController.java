package com.citaria.controller;

import com.citaria.dto.UsuarioDTO;
import com.citaria.model.RolUsuario;
import com.citaria.service.UsuarioService;
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
 * Controlador REST para la gestión de usuarios del sistema.
 */
@Tag(name = "Usuarios", description = "Gestión de usuarios y control de acceso")
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    @Autowired
    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @Operation(summary = "Obtener todos los usuarios de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping
    public ResponseEntity<List<UsuarioDTO>> obtenerTodos() {
        return ResponseEntity.ok(usuarioService.obtenerTodos());
    }

    @Operation(summary = "Obtener usuarios de la organización filtrados por rol")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/rol/{rol}")
    public ResponseEntity<List<UsuarioDTO>> obtenerPorRol(@PathVariable RolUsuario rol) {
        return ResponseEntity.ok(usuarioService.obtenerPorRol(rol));
    }

    @Operation(summary = "Obtener usuario autenticado")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Usuario autenticado obtenido correctamente")
    })
    @GetMapping("/me")
    public ResponseEntity<UsuarioDTO> obtenerActual() {
        return ResponseEntity.ok(usuarioService.obtenerActual());
    }

    @Operation(summary = "Obtener usuario por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Usuario encontrado"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @GetMapping("/{id}")
    public ResponseEntity<UsuarioDTO> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(usuarioService.obtenerPorId(id));
    }

    @Operation(summary = "Crear un nuevo usuario en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Usuario creado correctamente")
    })
    @PostMapping
    public ResponseEntity<UsuarioDTO> crear(@Valid @RequestBody UsuarioDTO dto) {
        return ResponseEntity.status(201).body(usuarioService.crear(dto));
    }

    @Operation(summary = "Actualizar un usuario existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Usuario actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioDTO> actualizar(@PathVariable Integer id, @Valid @RequestBody UsuarioDTO dto) {
        return ResponseEntity.ok(usuarioService.actualizar(id, dto));
    }

    @Operation(summary = "Anonimizar un usuario — elimina sus datos personales de forma irreversible")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Usuario anonimizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        usuarioService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
