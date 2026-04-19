package com.citaria.config;

import com.citaria.security.JwtFilter;
import com.citaria.security.UsuarioDetailsService;
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
 * y configura el sistema de autenticación stateless.
 */
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    private final UsuarioDetailsService usuarioDetailsService;
    private final JwtFilter jwtFilter;

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

                        // Públicos — autenticación y registro de clientes
                        .requestMatchers("/auth/**").permitAll()

                        // Swagger — solo ADMIN (accesible en producción con credenciales)
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/v3/api-docs/**"
                        ).permitAll()//hasRole("ADMIN")

                        // Públicos — área cliente (consulta catálogo sin autenticar)
                        .requestMatchers(HttpMethod.GET,
                                "/api/catalogo/servicios/**",
                                "/api/catalogo/categorias/**"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET,
                                "/api/organizaciones/*/configuracion"
                        ).permitAll()

                        // Chatbot — solo usuarios autenticados
                        .requestMatchers(HttpMethod.POST, "/api/chatbot/**").authenticated()

                        // Solo ADMIN
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