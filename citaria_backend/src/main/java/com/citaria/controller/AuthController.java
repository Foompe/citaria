package com.citaria.controller;

import com.citaria.dto.PeticionLoginDTO;
import com.citaria.dto.LoginRespuestaDTO;
import com.citaria.dto.RegistroRequestDTO;
import com.citaria.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador de autenticación. --> Gestiona el login y el registro de nuevos clientes.
 */
@Tag(name = "Autenticación", description = "Login, registro y gestión de tokens JWT")
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @Autowired
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Autentica un usuario y devuelve un token JWT.
     *
     * @param loginRequest DTO con email, password y organizacionId
     * @return token JWT si las credenciales son correctas, 401 en caso contrario
     */
    @Operation(summary = "Login — obtener token JWT")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login correcto, token generado"),
            @ApiResponse(responseCode = "401", description = "Credenciales incorrectas o cuenta desactivada"),
            @ApiResponse(responseCode = "404", description = "Organización no encontrada")
    })
    @PostMapping("/login")
    public ResponseEntity<LoginRespuestaDTO> login(@Valid @RequestBody PeticionLoginDTO loginRequest) {
        return ResponseEntity.ok(authService.login(loginRequest));
    }

    /**
     * Registra un nuevo cliente y devuelve un token JWT.

     * @param registroRequest DTO con tokenRegistro, email, password y datos del cliente
     * @return token JWT — el usuario queda autenticado tras el registro
     */
    @Operation(summary = "Registro de nuevo cliente")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Cliente registrado correctamente, token generado"),
            @ApiResponse(responseCode = "404", description = "Token de registro inválido"),
            @ApiResponse(responseCode = "409", description = "El email ya está registrado en esta organización")
    })
    @PostMapping("/registro")
    public ResponseEntity<LoginRespuestaDTO> registro(@Valid @RequestBody RegistroRequestDTO registroRequest) {
        return ResponseEntity.status(201).body(authService.registro(registroRequest));
    }
}