package com.urgences.api.common;

import java.time.Instant;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Format unique de toutes les erreurs de l'API.
 *
 * <pre>{ "status": 409, "code": "SOS_ALREADY_ACTIVE", "message": "…", "path": "/api/sos",
 *   "timestamp": "…", "fields": {…}, "details": {…} }</pre>
 */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ApiErrorResponse(
        int status,
        String code,
        String message,
        String path,
        Instant timestamp,
        Map<String, String> fields,
        Map<String, Object> details) {

    public static ApiErrorResponse of(int status, String code, String message, String path) {
        return new ApiErrorResponse(status, code, message, path, Instant.now(), Map.of(), Map.of());
    }
}
