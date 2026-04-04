package com.citaria.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración de Swagger/OpenAPI.
 * Habilita el botón Authorize para enviar tokens JWT en las peticiones.
 */
@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Citaria API",
                version = "1.0",
                description = "API REST para la plataforma de gestión de citas Citaria"
        ),
        security = @SecurityRequirement(name = "bearerAuth")
)
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT"
)
public class SwaggerConfig {
}