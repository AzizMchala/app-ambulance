package com.urgences.api.auth;

import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.urgences.api.user.Role;
import com.urgences.api.user.User;
import com.urgences.api.user.UserRepository;

/**
 * Crée un compte « secours » de démonstration si URGENCES_DEV_RESPONDER_EMAIL et
 * URGENCES_DEV_RESPONDER_PASSWORD sont définis. Il sert à produire de vraies décisions
 * (via /api/responder) tant que les modules E3/E6 n'existent pas. Ne jamais le définir en production.
 */
@Component
public class DevResponderSeeder implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DevResponderSeeder.class);

    private final UserRepository users;
    private final PasswordEncoder passwords;
    private final String email;
    private final String password;

    public DevResponderSeeder(UserRepository users, PasswordEncoder passwords,
            @Value("${urgences.dev-responder.email:}") String email,
            @Value("${urgences.dev-responder.password:}") String password) {
        this.users = users;
        this.passwords = passwords;
        this.email = email;
        this.password = password;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (email.isBlank() || password.length() < 8) return;
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        if (users.existsByEmailIgnoreCase(normalized)) return;
        users.save(new User("Équipe de régulation", normalized, passwords.encode(password), Role.RESPONDER));
        log.info("Compte secours de démonstration créé.");
    }
}
