package com.citaria.controller;

import com.citaria.dto.LoginRequestDTO;
import com.citaria.model.Usuario;
import com.citaria.repository.UsuarioDAO;
import com.citaria.security.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

/**
 * Controlador de autenticación.
 * Gestiona el login y la generación de tokens JWT.
 */
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UsuarioDAO usuarioDAO;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthController(UsuarioDAO usuarioDAO,
                          PasswordEncoder passwordEncoder) {
        this.usuarioDAO = usuarioDAO;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Autentica un usuario y devuelve un token JWT.
     *
     * @param request DTO con email y password
     * @return token JWT si las credenciales son correctas
     */
    @Operation(summary = "Login — obtener token JWT")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login correcto, token generado"),
            @ApiResponse(responseCode = "401", description = "Credenciales incorrectas")
    })
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO request) {
        Optional<Usuario> usuario = usuarioDAO.findByEmail(request.getEmail());

        if (usuario.isEmpty() ||
                !passwordEncoder.matches(request.getPassword(),
                        usuario.get().getPasswordHash())) {
            return ResponseEntity.status(401).build();
        }

        String token = JwtUtil.generateToken(
                usuario.get().getEmail(),
                usuario.get().getRol().name()
        );

        return ResponseEntity.ok(Map.of("token", token));
    }
}