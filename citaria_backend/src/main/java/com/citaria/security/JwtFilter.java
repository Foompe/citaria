package com.citaria.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Filtro JWT que intercepta cada petición HTTP.
 * Extrae el token del header Authorization, lo valida
 * y establece la autenticación en el contexto de Spring Security.
 */
public class JwtFilter extends OncePerRequestFilter {

    /**
     * Intercepta cada petición y procesa el token JWT si está presente.
     * Si el token es válido establece la autenticación en el contexto de seguridad.
     * Si no hay token o es inválido la petición continúa sin autenticación.
     *
     * @param request     petición HTTP entrante
     * @param response    respuesta HTTP
     * @param filterChain cadena de filtros a continuar
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader("Authorization");

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            try {
                String email = JwtUtil.getEmail(token);
                String role = JwtUtil.getRole(token);

                UsernamePasswordAuthenticationToken autenticacion =
                        new UsernamePasswordAuthenticationToken(
                                email,
                                null,
                                List.of(new SimpleGrantedAuthority("ROLE_" + role))
                        );

                SecurityContextHolder.getContext().setAuthentication(autenticacion);
            } catch (Exception e) {
                SecurityContextHolder.clearContext();
            }
        }

        filterChain.doFilter(request, response);
    }
}