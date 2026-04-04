package com.citaria.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

/**
 * Utilidad para la generación y validación de tokens JWT.
 * Genera tokens con email y rol del usuario.
 * Valida implícitamente el token al extraer sus claims.
 */
public class JwtUtil {

    private static final String SECRET =
            "SECRETO_ELIMINADO";

    private static final Key SECRET_KEY =
            Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));

    /**
     * Genera un token JWT firmado con email y rol del usuario.
     *
     * @param email email del usuario
     * @param role rol del usuario
     * @return token JWT firmado
     */
    public static String generateToken(String email, String role) {
        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + 3600000))
                .signWith(SECRET_KEY)
                .compact();
    }

    /**
     * Extrae el email del token JWT.
     * Valida implícitamente el token — lanza excepción si es inválido o expirado.
     *
     * @param token token JWT
     * @return email del usuario
     */
    public static String getEmail(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * Extrae el rol del token JWT.
     * Valida implícitamente el token — lanza excepción si es inválido o expirado.
     *
     * @param token token JWT
     * @return rol del usuario
     */
    public static String getRole(String token) {
        return getClaims(token).get("role", String.class);
    }

    private static Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith((javax.crypto.SecretKey) SECRET_KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
