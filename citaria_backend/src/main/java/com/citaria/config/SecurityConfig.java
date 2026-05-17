package com.citaria.config;

import com.citaria.security.JwtFilter;
import com.citaria.security.UsuarioDetailsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configuración de seguridad de la aplicación.
 * Define endpoints públicos y protegidos, registra el filtro JWT
 * y configura el sistema de autenticación.
 */
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    private final UsuarioDetailsService usuarioDetailsService;
    private final JwtFilter jwtFilter;

    @Autowired
    public SecurityConfig(UsuarioDetailsService usuarioDetailsService,
                          JwtFilter jwtFilter) {
        this.usuarioDetailsService = usuarioDetailsService;
        this.jwtFilter = jwtFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth

                        // Públicos
                        .requestMatchers("/auth/**").permitAll()

                        // Swagger
                        .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**").permitAll()


                        // Público — configuración visual por token de registro
                        .requestMatchers(HttpMethod.GET, "/api/organizaciones/configuracion",
                                "/api/organizaciones/publico",
                                "/api/organizaciones/*/configuracion").permitAll()


                        // Chatbot — solo usuarios autenticados
                        .requestMatchers(HttpMethod.POST, "/api/chatbot/**").authenticated()


                        // Disponibilidad — accesible por ADMIN, EMPLEADO y CLIENTE autenticados
                        .requestMatchers(HttpMethod.GET, "/api/disponibilidad").authenticated()


                        // ROLE_CLIENT — sus propias reservas y perfil
                        .requestMatchers(HttpMethod.GET, "/api/reservas/cliente/**")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")
                        .requestMatchers(HttpMethod.GET, "/api/clientes/{id}")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")
                        .requestMatchers(HttpMethod.PUT, "/api/clientes/{id}")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")
                        .requestMatchers(HttpMethod.POST, "/api/clientes/{id}/imagen")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")
                        .requestMatchers(HttpMethod.PATCH, "/api/reservas/*/cancelar")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")
                        .requestMatchers(HttpMethod.POST, "/api/reservas/cliente/*")
                        .hasAnyRole("ADMIN", "EMPLEADO", "CLIENTE")


                        // Solo ADMIN
                        .requestMatchers(HttpMethod.GET, "/api/usuarios/me").authenticated()
                        .requestMatchers("/api/usuarios/**").hasRole("ADMIN")
                        .requestMatchers("/api/empleados/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/catalogo/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/catalogo/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/catalogo/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/organizaciones/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/organizaciones/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/organizaciones/**").hasRole("ADMIN")


                        // ADMIN y EMPLEADO
                        .requestMatchers("/api/reservas/**").hasAnyRole("ADMIN", "EMPLEADO")
                        .requestMatchers("/api/clientes/**").hasAnyRole("ADMIN", "EMPLEADO")
                        .requestMatchers("/api/estadisticas/**").hasAnyRole("ADMIN", "EMPLEADO")


                        // Cualquier autenticado
                        .anyRequest().authenticated()
                )
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((request, response, authException) ->
                                response.sendError(401, "No autenticado"))
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
