package com.citaria.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

/**
 * Filtro JWT que intercepta cada petición HTTP.
 * Extrae el token del header Authorization, valida su firma y expiración,
 * carga el usuario desde BD usando el username compuesto
 * y verifica que esté activo antes de autenticar.
 */
@Component
public class JwtFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(JwtFilter.class);
    private static final String PREFIJO_BEARER = "Bearer ";
    private static final String CABECERA_AUTHORIZATION = "Authorization";
    private final JwtUtil jwtUtil;
    private final UsuarioDetailsService usuarioDetailsService;

    @Autowired
    public JwtFilter(JwtUtil jwtUtil, UsuarioDetailsService usuarioDetailsService) {
        this.jwtUtil = jwtUtil;
        this.usuarioDetailsService = usuarioDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String cabeceraAutorizacion = request.getHeader(CABECERA_AUTHORIZATION);

        if (cabeceraAutorizacion == null || !cabeceraAutorizacion.startsWith(PREFIJO_BEARER)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = cabeceraAutorizacion.substring(PREFIJO_BEARER.length());

        try {
            String email = jwtUtil.getEmail(token);
            Integer organizacionId = jwtUtil.getOrganizacionId(token);

            if (email != null && organizacionId != null
                    && SecurityContextHolder.getContext().getAuthentication() == null) {

                String usernameCompuesto = UsuarioDetailsService.construirUsername(email, organizacionId);
                UserDetails usuarioDetails = usuarioDetailsService.loadUserByUsername(usernameCompuesto);

                // Rechazamos cuentas inactivas
                if (!usuarioDetails.isEnabled()) {
                    log.warn("Intento de acceso con cuenta desactivada para email: {}", email);
                    SecurityContextHolder.clearContext();
                    filterChain.doFilter(request, response);
                    return;
                }

                UsernamePasswordAuthenticationToken autenticacion =
                        new UsernamePasswordAuthenticationToken(
                                usuarioDetails,
                                null,
                                usuarioDetails.getAuthorities()
                        );
                autenticacion.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );
                SecurityContextHolder.getContext().setAuthentication(autenticacion);
            }

        } catch (UsernameNotFoundException ex) {
            log.warn("Token JWT con usuario inexistente en base de datos");
            SecurityContextHolder.clearContext();
        } catch (Exception ex) {
            log.debug("Token JWT inválido o expirado: {}", ex.getMessage());
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }
}
