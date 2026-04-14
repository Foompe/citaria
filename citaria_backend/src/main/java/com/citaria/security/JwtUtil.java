package com.citaria.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * Utilidad para la generación y validación de tokens JWT.
 * Genera tokens con email y rol del usuario.
 * Valida implícitamente el token al extraer sus claims.
 */
@Component
public class JwtUtil {

    private final SecretKey secretKey;

    public JwtUtil(@Value("${jwt.secret}") String secret) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Genera un token JWT firmado con email y rol del usuario.
     *
     * @param email email del usuario
     * @param role rol del usuario
     * @return token JWT firmado
     */
    public String generateToken(String email, String role) {
        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + 3600000))
                .signWith(secretKey)
                .compact();
    }

    /**
     * Extrae el email del token JWT.
     * Valida implícitamente el token — lanza excepción si es inválido o expirado.
     *
     * @param token token JWT
     * @return email del usuario
     */
    public String getEmail(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * Extrae el rol del token JWT.
     * Valida implícitamente el token — lanza excepción si es inválido o expirado.
     *
     * @param token token JWT
     * @return rol del usuario
     */
    public String getRole(String token) {
        return getClaims(token).get("role", String.class);
    }

    private Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
