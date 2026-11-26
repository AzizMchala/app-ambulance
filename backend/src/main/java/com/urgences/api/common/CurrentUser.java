package com.urgences.api.common;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;

/** Identifiant de l'utilisateur connecté, tiré du jeton vérifié (claim {@code sub}). */
public final class CurrentUser {

    private CurrentUser() {
    }

    /** À utiliser avec {@link AuthenticationPrincipal} : {@code @AuthenticationPrincipal Jwt jwt}. */
    public static long id(Jwt jwt) {
        return Long.parseLong(jwt.getSubject());
    }
}
