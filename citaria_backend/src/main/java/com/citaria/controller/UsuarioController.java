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

    @Operation(summary = "Obtener todos los usuarios de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/organizacion/{organizacionId}")
    public ResponseEntity<List<UsuarioDTO>> obtenerTodos(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(usuarioService.obtenerTodos(organizacionId));
    }

    @Operation(summary = "Obtener usuarios de una organización filtrados por rol")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/organizacion/{organizacionId}/rol/{rol}")
    public ResponseEntity<List<UsuarioDTO>> obtenerPorRol(@PathVariable Integer organizacionId,
                                                          @PathVariable RolUsuario rol) {
        return ResponseEntity.ok(usuarioService.obtenerPorRol(organizacionId, rol));
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

    @Operation(summary = "Crear un nuevo usuario en una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Usuario creado correctamente")
    })
    @PostMapping("/organizacion/{organizacionId}")
    public ResponseEntity<UsuarioDTO> crear(@PathVariable Integer organizacionId,
                                            @Valid @RequestBody UsuarioDTO dto) {
        return ResponseEntity.status(201).body(usuarioService.crear(organizacionId, dto));
    }

    @Operation(summary = "Actualizar un usuario existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Usuario actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioDTO> actualizar(@PathVariable Integer id,
                                                 @Valid @RequestBody UsuarioDTO dto) {
        return ResponseEntity.ok(usuarioService.actualizar(id, dto));
    }

    @Operation(summary = "Eliminar un usuario")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Usuario eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        if (usuarioService.eliminar(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}