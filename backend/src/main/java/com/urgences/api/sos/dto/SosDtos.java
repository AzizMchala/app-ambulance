package com.urgences.api.sos.dto;

import java.time.Instant;

import com.urgences.api.sos.domain.LocationSource;
import com.urgences.api.sos.domain.SosHistory;
import com.urgences.api.sos.domain.SosRequest;
import com.urgences.api.sos.domain.SosStatus;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

/** Contrat REST du module E2 (voir docs/api-contract.md). */
public final class SosDtos {

    private SosDtos() {
    }

    @Schema(description = "Nouvelle demande SOS. Des coordonnées (GPS ou LAST_KNOWN) ou une adresse (MANUAL) sont obligatoires.")
    public record CreateSosRequest(
            @Schema(description = "UUID généré par le téléphone, identique pour toutes les tentatives d'une même alerte")
            @NotNull @Pattern(regexp = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
            String clientRequestId,
            @NotNull LocationSource locationSource,
            @DecimalMin("-90") @DecimalMax("90") Double latitude,
            @DecimalMin("-180") @DecimalMax("180") Double longitude,
            @Schema(description = "Précision en mètres") @PositiveOrZero @Max(100_000) Double locationAccuracy,
            @Schema(description = "Moment réel du relevé GPS") Instant locationCapturedAt,
            @Size(max = 255) String address) {
    }

    public record SosResponse(
            long id,
            Double latitude,
            Double longitude,
            String address,
            LocationSource locationSource,
            Double locationAccuracy,
            Instant locationCapturedAt,
            SosStatus status,
            String decisionMessage,
            Instant createdAt,
            Instant updatedAt) {

        public static SosResponse of(SosRequest r) {
            return new SosResponse(r.getId(), r.getLatitude(), r.getLongitude(), r.getAddress(),
                r.getLocationSource(), r.getLocationAccuracy(), r.getLocationCapturedAt(), r.getStatus(),
                r.getDecisionMessage(), r.getCreatedAt(), r.getUpdatedAt());
        }
    }

    @Schema(description = "Réponse légère pour le suivi en direct")
    public record SosStatusResponse(long id, SosStatus status, String decisionMessage, Instant updatedAt) {

        public static SosStatusResponse of(SosRequest r) {
            return new SosStatusResponse(r.getId(), r.getStatus(), r.getDecisionMessage(), r.getUpdatedAt());
        }
    }

    public record SosHistoryResponse(
            long id,
            long sosRequestId,
            SosStatus oldStatus,
            SosStatus newStatus,
            String description,
            Instant createdAt) {

        public static SosHistoryResponse of(SosHistory h) {
            return new SosHistoryResponse(h.getId(), h.getSosRequestId(), h.getOldStatus(), h.getNewStatus(),
                h.getDescription(), h.getCreatedAt());
        }
    }

    @Schema(description = "Décision des secours. Un refus exige un message.")
    public record UpdateSosStatusRequest(@NotNull SosStatus status, @Size(max = 500) String message) {
    }

    @Schema(description = "Vue des secours : la demande et le patient concerné")
    public record ResponderSosResponse(SosResponse request, long patientId, String patientName) {

        public static ResponderSosResponse of(SosRequest r) {
            return new ResponderSosResponse(SosResponse.of(r), r.getPatient().getId(), r.getPatient().getFullName());
        }
    }
}
