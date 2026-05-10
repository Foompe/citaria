package com.citaria.service;

import com.citaria.dto.PeticionLoginDTO;
import com.citaria.dto.LoginRespuestaDTO;
import com.citaria.dto.RegistroRequestDTO;

/**
 * Define las operaciones relacionadas con el login, registro y generación de tokens JWT.
 */
public interface AuthService {

    /**
     * Autentica al usuario con sus credenciales y devuelve un token JWT.
     *
     * @param loginRequest DTO con email, password y organizacionId
     * @return DTO con el token JWT generado
     * @throws org.springframework.security.core.AuthenticationException si las credenciales
     *         son inválidas o la cuenta está desactivada
     * @throws com.citaria.exception.RecursoNoEncontradoException si la organización no existe
     */
    LoginRespuestaDTO login(PeticionLoginDTO loginRequest);

    /**
     * Registra un nuevo usuario con rol CLIENTE y devuelve un token JWT.
     *
     * @param registroRequest DTO con tokenRegistro, email, password y datos del cliente
     * @return DTO con el token JWT — el usuario queda autenticado tras el registro
     * @throws com.citaria.exception.RecursoNoEncontradoException si el tokenRegistro es inválido
     * @throws com.citaria.exception.EmailYaRegistradoException si el email ya tiene usuario
     */
    LoginRespuestaDTO registro(RegistroRequestDTO registroRequest);
}