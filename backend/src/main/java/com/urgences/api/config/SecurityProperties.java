package com.urgences.api.config;

import java.time.Duration;
import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Réglages de sécurité, lus depuis les variables d'environnement.
 *
 * @param jwtSecret                 secret HS256, 32 caractères minimum
 * @param tokenValidity             durée de vie d'un jeton d'accès
 * @param corsAllowedOriginPatterns origines autorisées (Flutter web en développement)
 */
@ConfigurationProperties("urgences.security")
public record SecurityProperties(String jwtSecret, Duration tokenValidity, List<String> corsAllowedOriginPatterns) {

    public SecurityProperties {
        if (jwtSecret == null || jwtSecret.length() < 32) {
            throw new IllegalStateException("URGENCES_JWT_SECRET doit contenir au moins 32 caractères.");
        }
        if (tokenValidity == null) tokenValidity = Duration.ofHours(12);
        if (corsAllowedOriginPatterns == null) corsAllowedOriginPatterns = List.of();
    }
}
