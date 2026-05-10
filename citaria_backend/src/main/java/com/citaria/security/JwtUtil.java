package com.citaria.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * Generación y validación de tokens JWT.
 * El token incluye email, rol y organizacionId del usuario.
 */
@Component
public class JwtUtil {

    private static final String CLAIM_ROL = "rol";
    private static final String CLAIM_ORGANIZACION_ID = "organizacionId";
    private final SecretKey secretKey;
    private final long expiracionMs;

    @Autowired
    public JwtUtil(@Value("${jwt.secret}") String secret, @Value("${jwt.expiration-ms}") long expiracionMs) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expiracionMs = expiracionMs;
    }

    /**
     * Genera un token JWT firmado con email, rol y organizacionId del usuario.
     *
     * @return token JWT firmado
     */
    public String generateToken(String email, String rol, Integer organizacionId) {
        return Jwts.builder()
                .subject(email)
                .claim(CLAIM_ROL, rol)
                .claim(CLAIM_ORGANIZACION_ID, organizacionId)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expiracionMs))
                .signWith(secretKey)
                .compact();
    }

    /**
     * Extrae el email del token JWT.
     *
     * @param token token JWT
     * @return email del usuario
     */
    public String getEmail(String token) {
        return getClaims(token).getSubject();
    }

    /**
     * Extrae el rol del token JWT.
     *
     * @param token token JWT
     * @return rol del usuario
     */
    //TODO: Revisar si se borra
    public String getRol(String token) {
        return getClaims(token).get(CLAIM_ROL, String.class);
    }

    /**
     * Extrae el organizacionId del token JWT.
     *
     * @param token token JWT
     * @return id de la organización del usuario
     */
    public Integer getOrganizacionId(String token) {
        return getClaims(token).get(CLAIM_ORGANIZACION_ID, Integer.class);
    }

    private Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}