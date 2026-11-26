package com.urgences.api.common;

import java.util.Map;

import org.springframework.http.HttpStatus;

/**
 * Refus métier prévu, transformé en réponse JSON uniforme par {@link GlobalExceptionHandler}.
 * Le {@code code} est stable : l'application mobile s'en sert pour choisir son message.
 */
public class ApiException extends RuntimeException {

    private final HttpStatus status;
    private final String code;
    private final transient Map<String, Object> details;
    private final transient Map<String, String> fields;

    public ApiException(HttpStatus status, String code, String message) {
        this(status, code, message, Map.of());
    }

    public ApiException(HttpStatus status, String code, String message, Map<String, Object> details) {
        super(message);
        this.status = status;
        this.code = code;
        this.details = details;
        this.fields = Map.of();
    }

    private ApiException(Map<String, String> fields) {
        super("Certaines informations sont invalides.");
        this.status = HttpStatus.BAD_REQUEST;
        this.code = "VALIDATION_FAILED";
        this.details = Map.of();
        this.fields = Map.copyOf(fields);
    }

    /** Erreurs de champs détectées dans un service, au même format que la validation des DTO. */
    public static ApiException validation(Map<String, String> fields) {
        return new ApiException(fields);
    }

    public static ApiException notFound(String code, String message) {
        return new ApiException(HttpStatus.NOT_FOUND, code, message);
    }

    public static ApiException conflict(String code, String message) {
        return new ApiException(HttpStatus.CONFLICT, code, message);
    }

    public HttpStatus status() {
        return status;
    }

    public String code() {
        return code;
    }

    public Map<String, Object> details() {
        return details;
    }

    public Map<String, String> fields() {
        return fields;
    }
}
