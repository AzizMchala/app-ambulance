package com.urgences.api.auth;

import java.time.Instant;
import java.util.List;
import java.util.Locale;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.urgences.api.auth.AuthDtos.AuthResponse;
import com.urgences.api.auth.AuthDtos.LoginRequest;
import com.urgences.api.auth.AuthDtos.RegisterRequest;
import com.urgences.api.auth.AuthDtos.UserResponse;
import com.urgences.api.common.ApiException;
import com.urgences.api.config.SecurityProperties;
import com.urgences.api.user.Role;
import com.urgences.api.user.User;
import com.urgences.api.user.UserRepository;

/** Inscription des patients, connexion et émission des jetons d'accès. */
@Service
public class AuthService {

    private final UserRepository users;
    private final PasswordEncoder passwords;
    private final JwtEncoder jwtEncoder;
    private final SecurityProperties properties;

    /** Hachage factice : la connexion prend le même temps que l'e-mail existe ou non. */
    private final String dummyHash;

    public AuthService(UserRepository users, PasswordEncoder passwords, JwtEncoder jwtEncoder,
            SecurityProperties properties) {
        this.users = users;
        this.passwords = passwords;
        this.jwtEncoder = jwtEncoder;
        this.properties = properties;
        this.dummyHash = passwords.encode("timing-equalizer-not-a-password");
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalize(request.email());
        if (users.existsByEmailIgnoreCase(email)) {
            throw ApiException.conflict("EMAIL_TAKEN", "Cette adresse e-mail est déjà utilisée.");
        }
        var user = users.save(new User(request.fullName().trim(), email, passwords.encode(request.password()),
            Role.PATIENT));
        return issue(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        var user = users.findByEmailIgnoreCase(normalize(request.email())).orElse(null);
        boolean ok = passwords.matches(request.password(), user == null ? dummyHash : user.getPasswordHash());
        if (user == null || !ok) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "INVALID_CREDENTIALS", "E-mail ou mot de passe incorrect.");
        }
        return issue(user);
    }

    @Transactional(readOnly = true)
    public UserResponse me(long userId) {
        return users.findById(userId).map(UserResponse::of)
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHENTICATED", "Compte introuvable."));
    }

    private AuthResponse issue(User user) {
        Instant now = Instant.now();
        Instant expiresAt = now.plus(properties.tokenValidity());
        var claims = JwtClaimsSet.builder()
            .issuer("urgences-api")
            .subject(String.valueOf(user.getId()))
            .issuedAt(now)
            .expiresAt(expiresAt)
            .claim("roles", List.of(user.getRole().name()))
            .build();
        var header = JwsHeader.with(MacAlgorithm.HS256).build();
        String token = jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
        return new AuthResponse(token, "Bearer", expiresAt, UserResponse.of(user));
    }

    private static String normalize(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
