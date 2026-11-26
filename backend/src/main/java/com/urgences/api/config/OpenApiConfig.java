package com.urgences.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

/** Documentation interactive : /swagger-ui.html (bouton « Authorize » pour coller le jeton). */
@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI urgencesOpenApi() {
        return new OpenAPI()
            .info(new Info()
                .title("Urgences médicales — API")
                .version("0.1.0")
                .description("API REST unique. Module E2 : demandes SOS, suivi et historique."))
            .components(new Components().addSecuritySchemes("bearer",
                new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")))
            .addSecurityItem(new SecurityRequirement().addList("bearer"));
    }
}
