package com.citaria.service;

import com.citaria.dto.LoginRequestDTO;
import com.citaria.dto.LoginRespuestaDTO;
import com.citaria.dto.RegistroRequestDTO;

/**
 * Contrato del servicio de autenticación.
 * Define las operaciones relacionadas con el login, registro y generación de tokens JWT.
 */
public interface AuthService {

    /**
     * Autentica al usuario con sus credenciales y devuelve un token JWT.
     * Usa username compuesto (email:organizacionId) para identificar unívocamente
     * al usuario cuando el mismo email puede existir en múltiples organizaciones.
     *
     * @param loginRequest DTO con email, password y organizacionId
     * @return DTO con el token JWT generado
     * @throws org.springframework.security.core.AuthenticationException si las credenciales
     *         son inválidas o la cuenta está desactivada
     * @throws com.citaria.exception.RecursoNoEncontradoException si la organización no existe
     */
    LoginRespuestaDTO login(LoginRequestDTO loginRequest);

    /**
     * Registra un nuevo usuario con rol CLIENTE y devuelve un token JWT.
     * La organización se identifica mediante un tokenRegistro opaco generado
     * al crear la organización — el cliente lo obtiene del enlace o QR de la empresa.
     * Si el email coincide con una ficha de cliente existente en la organización,
     * el usuario se vincula automáticamente a esa ficha.
     *
     * @param registroRequest DTO con tokenRegistro, email, password y datos del cliente
     * @return DTO con el token JWT — el usuario queda autenticado tras el registro
     * @throws com.citaria.exception.RecursoNoEncontradoException si el tokenRegistro es inválido
     * @throws com.citaria.exception.EmailYaRegistradoException si el email ya tiene usuario
     */
    LoginRespuestaDTO registro(RegistroRequestDTO registroRequest);
}