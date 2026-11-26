package com.urgences.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * API REST unique de l'application de gestion des urgences médicales.
 * Chaque module (E1 à E6) ajoute son propre paquet à côté de {@code sos} ; la sécurité,
 * les erreurs et les comptes sont partagés.
 */
@SpringBootApplication
@ConfigurationPropertiesScan
public class UrgencesApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(UrgencesApiApplication.class, args);
    }
}
