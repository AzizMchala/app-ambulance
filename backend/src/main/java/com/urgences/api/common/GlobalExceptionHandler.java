package com.urgences.api.common;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import jakarta.servlet.http.HttpServletRequest;

/** Gestion centralisée : toute erreur devient un {@link ApiErrorResponse}, jamais une trace Java. */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ApiException.class)
    ResponseEntity<ApiErrorResponse> api(ApiException e, HttpServletRequest request) {
        var body = new ApiErrorResponse(e.status().value(), e.code(), e.getMessage(), request.getRequestURI(),
            Instant.now(), e.fields(), e.details());
        return ResponseEntity.status(e.status()).body(body);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiErrorResponse> invalid(MethodArgumentNotValidException e, HttpServletRequest request) {
        Map<String, String> fields = new LinkedHashMap<>();
        e.getBindingResult().getFieldErrors().forEach(f -> fields.putIfAbsent(f.getField(), f.getCode()));
        e.getBindingResult().getGlobalErrors().forEach(g -> fields.putIfAbsent(g.getObjectName(), g.getCode()));
        var body = new ApiErrorResponse(400, "VALIDATION_FAILED", "Certaines informations sont invalides.",
            request.getRequestURI(), Instant.now(), fields, Map.of());
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler({HandlerMethodValidationException.class, MethodArgumentTypeMismatchException.class})
    ResponseEntity<ApiErrorResponse> badParameter(Exception e, HttpServletRequest request) {
        return ResponseEntity.badRequest().body(
            ApiErrorResponse.of(400, "INVALID_PARAMETER", "Paramètre invalide.", request.getRequestURI()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<ApiErrorResponse> unreadable(HttpServletRequest request) {
        return ResponseEntity.badRequest().body(
            ApiErrorResponse.of(400, "MALFORMED_REQUEST", "Corps de requête illisible.", request.getRequestURI()));
    }

    @ExceptionHandler(OptimisticLockingFailureException.class)
    ResponseEntity<ApiErrorResponse> concurrent(HttpServletRequest request) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ApiErrorResponse.of(409, "CONCURRENT_UPDATE",
            "La demande vient d'être modifiée. Rechargez-la.", request.getRequestURI()));
    }

    @ExceptionHandler(NoResourceFoundException.class)
    ResponseEntity<ApiErrorResponse> noRoute(HttpServletRequest request) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ApiErrorResponse.of(404, "NOT_FOUND", "Ressource introuvable.", request.getRequestURI()));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    ResponseEntity<ApiErrorResponse> method(HttpServletRequest request) {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
            .body(ApiErrorResponse.of(405, "METHOD_NOT_ALLOWED", "Méthode non autorisée.", request.getRequestURI()));
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiErrorResponse> unexpected(Exception e, HttpServletRequest request) {
        // Seulement le type et le chemin : le message peut contenir des données de la requête.
        log.error("Erreur inattendue sur {} : {}", request.getRequestURI(), e.getClass().getName(), e);
        return ResponseEntity.internalServerError().body(
            ApiErrorResponse.of(500, "INTERNAL_ERROR", "Erreur interne du serveur.", request.getRequestURI()));
    }
}
