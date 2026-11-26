package com.urgences.api.sos.web;

import java.util.List;
import java.util.Set;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.urgences.api.common.CurrentUser;
import com.urgences.api.common.PageResponse;
import com.urgences.api.sos.ResponderSosService;
import com.urgences.api.sos.domain.SosStatus;
import com.urgences.api.sos.dto.SosDtos.ResponderSosResponse;
import com.urgences.api.sos.dto.SosDtos.SosHistoryResponse;
import com.urgences.api.sos.dto.SosDtos.UpdateSosStatusRequest;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

/** Espace hôpital (rôle RESPONDER) : file des demandes, détail et décisions. */
@RestController
@RequestMapping("/api/responder/sos")
@Tag(name = "E2 — SOS (secours)")
public class ResponderSosController {

    private final ResponderSosService responder;

    public ResponderSosController(ResponderSosService responder) {
        this.responder = responder;
    }

    @GetMapping
    @Operation(summary = "File des demandes (par défaut : actives), de la plus ancienne à la plus récente")
    public PageResponse<ResponderSosResponse> list(@RequestParam(required = false) Set<SosStatus> status,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return responder.list(status, page, size);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détail d'une demande, avec le patient concerné")
    public ResponderSosResponse get(@PathVariable long id) {
        return responder.get(id);
    }

    @GetMapping("/{id}/history")
    @Operation(summary = "Changements de statut d'une demande, du plus ancien au plus récent")
    public List<SosHistoryResponse> history(@PathVariable long id) {
        return responder.history(id);
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Décider ou faire avancer une demande (un refus exige un message)")
    public ResponderSosResponse updateStatus(@AuthenticationPrincipal Jwt jwt, @PathVariable long id,
            @Valid @RequestBody UpdateSosStatusRequest body) {
        return responder.updateStatus(CurrentUser.id(jwt), id, body);
    }
}
