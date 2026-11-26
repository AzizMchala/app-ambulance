package com.urgences.api.sos.web;

import java.net.URI;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.urgences.api.common.CurrentUser;
import com.urgences.api.common.PageResponse;
import com.urgences.api.sos.SosService;
import com.urgences.api.sos.dto.SosDtos.CreateSosRequest;
import com.urgences.api.sos.dto.SosDtos.SosHistoryResponse;
import com.urgences.api.sos.dto.SosDtos.SosResponse;
import com.urgences.api.sos.dto.SosDtos.SosStatusResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

/** Module E2, côté patient. Le patient est toujours celui du jeton : aucun identifiant patient dans l'URL. */
@RestController
@RequestMapping("/api/sos")
@Tag(name = "E2 — SOS (patient)")
public class SosController {

    private final SosService sos;

    public SosController(SosService sos) {
        this.sos = sos;
    }

    @PostMapping
    @Operation(summary = "Envoyer une demande SOS")
    @ApiResponse(responseCode = "201", description = "Demande enregistrée")
    @ApiResponse(responseCode = "200", description = "Même clientRequestId déjà reçu : la demande existante est renvoyée")
    @ApiResponse(responseCode = "409", description = "SOS_ALREADY_ACTIVE : une demande est déjà en cours (details.activeRequestId)")
    public ResponseEntity<SosResponse> create(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody CreateSosRequest body) {
        var result = sos.create(CurrentUser.id(jwt), body);
        if (!result.created()) return ResponseEntity.ok(result.request());
        return ResponseEntity.created(URI.create("/api/sos/" + result.request().id())).body(result.request());
    }

    @GetMapping
    @Operation(summary = "Mes demandes, de la plus récente à la plus ancienne")
    public PageResponse<SosResponse> list(@AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return sos.list(CurrentUser.id(jwt), page, size);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une de mes demandes")
    public SosResponse get(@AuthenticationPrincipal Jwt jwt, @PathVariable long id) {
        return sos.get(CurrentUser.id(jwt), id);
    }

    @GetMapping("/{id}/status")
    @Operation(summary = "Statut courant (suivi en direct, réponse légère)")
    public SosStatusResponse status(@AuthenticationPrincipal Jwt jwt, @PathVariable long id) {
        return sos.status(CurrentUser.id(jwt), id);
    }

    @GetMapping("/{id}/history")
    @Operation(summary = "Changements de statut, du plus ancien au plus récent")
    public List<SosHistoryResponse> history(@AuthenticationPrincipal Jwt jwt, @PathVariable long id) {
        return sos.history(CurrentUser.id(jwt), id);
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Annuler une demande encore en attente")
    @ApiResponse(responseCode = "409", description = "INVALID_STATUS_TRANSITION : la demande a déjà reçu une décision")
    public ResponseEntity<SosResponse> cancel(@AuthenticationPrincipal Jwt jwt, @PathVariable long id) {
        return ResponseEntity.status(HttpStatus.OK).body(sos.cancel(CurrentUser.id(jwt), id));
    }
}
