package com.urgences.api.sos;

import java.time.Duration;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.urgences.api.common.ApiException;
import com.urgences.api.common.PageResponse;
import com.urgences.api.sos.domain.LocationSource;
import com.urgences.api.sos.domain.SosHistory;
import com.urgences.api.sos.domain.SosRequest;
import com.urgences.api.sos.domain.SosStatus;
import com.urgences.api.sos.dto.SosDtos.CreateSosRequest;
import com.urgences.api.sos.dto.SosDtos.SosHistoryResponse;
import com.urgences.api.sos.dto.SosDtos.SosResponse;
import com.urgences.api.sos.dto.SosDtos.SosStatusResponse;
import com.urgences.api.user.UserRepository;

/**
 * Opérations du patient sur ses propres demandes. Chaque lecture passe par {@link #owned} :
 * une demande d'un autre patient répond 404, sans révéler qu'elle existe.
 */
@Service
public class SosService {

    static final int MAX_PAGE_SIZE = 50;
    private static final int MIN_ADDRESS_LENGTH = 5;
    /** Tolérance d'horloge entre le téléphone et le serveur. */
    private static final Duration CLOCK_SKEW = Duration.ofMinutes(2);

    private final SosRequestRepository requests;
    private final SosHistoryRepository history;
    private final UserRepository users;

    public SosService(SosRequestRepository requests, SosHistoryRepository history, UserRepository users) {
        this.requests = requests;
        this.history = history;
        this.users = users;
    }

    /** Résultat de création : {@code created = false} quand la même alerte avait déjà été enregistrée. */
    public record Creation(SosResponse request, boolean created) {
    }

    @Transactional
    public Creation create(long patientId, CreateSosRequest body) {
        String address = clean(body.address());
        validateLocation(body, address);

        // Verrou sur le patient : deux envois simultanés ne créent jamais deux demandes actives.
        var patient = users.lockById(patientId)
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHENTICATED", "Compte introuvable."));

        var existing = requests.findByPatientIdAndClientRequestId(patientId, body.clientRequestId());
        if (existing.isPresent()) return new Creation(SosResponse.of(existing.get()), false);

        requests.findFirstByPatientIdAndStatusInOrderByCreatedAtDesc(patientId, SosStatus.active())
            .ifPresent(active -> {
                throw new ApiException(HttpStatus.CONFLICT, "SOS_ALREADY_ACTIVE",
                    "Vous avez déjà une demande SOS en cours.", Map.of("activeRequestId", active.getId()));
            });

        boolean manual = body.locationSource() == LocationSource.MANUAL;
        var request = requests.save(new SosRequest(patient, body.clientRequestId(),
            manual ? null : body.latitude(), manual ? null : body.longitude(), address, body.locationSource(),
            manual ? null : body.locationAccuracy(), manual ? null : body.locationCapturedAt()));
        history.save(new SosHistory(request.getId(), null, SosStatus.PENDING, "Demande envoyée par le patient.",
            patientId));
        return new Creation(SosResponse.of(request), true);
    }

    @Transactional(readOnly = true)
    public PageResponse<SosResponse> list(long patientId, int page, int size) {
        if (page < 0 || size < 1 || size > MAX_PAGE_SIZE) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "INVALID_PARAMETER",
                "page >= 0 et size entre 1 et " + MAX_PAGE_SIZE + ".");
        }
        var pageable = PageRequest.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id")));
        return PageResponse.of(requests.findByPatientId(patientId, pageable), SosResponse::of);
    }

    @Transactional(readOnly = true)
    public SosResponse get(long patientId, long id) {
        return SosResponse.of(owned(patientId, id));
    }

    @Transactional(readOnly = true)
    public SosStatusResponse status(long patientId, long id) {
        return SosStatusResponse.of(owned(patientId, id));
    }

    @Transactional(readOnly = true)
    public List<SosHistoryResponse> history(long patientId, long id) {
        owned(patientId, id);
        return history.findBySosRequestIdOrderByCreatedAtAscIdAsc(id).stream().map(SosHistoryResponse::of).toList();
    }

    /** Le patient ne peut annuler qu'une demande encore sans décision. */
    @Transactional
    public SosResponse cancel(long patientId, long id) {
        var request = owned(patientId, id);
        if (request.getStatus() != SosStatus.PENDING) {
            throw ApiException.conflict("INVALID_STATUS_TRANSITION",
                "Cette demande a déjà reçu une décision et ne peut plus être annulée.");
        }
        SosStatus old = request.moveTo(SosStatus.CANCELLED, null);
        history.save(new SosHistory(id, old, SosStatus.CANCELLED, "Demande annulée par le patient.", patientId));
        return SosResponse.of(requests.saveAndFlush(request));
    }

    private SosRequest owned(long patientId, long id) {
        return requests.findByIdAndPatientId(id, patientId)
            .orElseThrow(() -> ApiException.notFound("SOS_NOT_FOUND", "Demande introuvable."));
    }

    /** Règles croisées que les annotations ne peuvent pas exprimer. */
    private static void validateLocation(CreateSosRequest body, String address) {
        Map<String, String> fields = new LinkedHashMap<>();
        boolean hasLat = body.latitude() != null;
        boolean hasLng = body.longitude() != null;
        if (body.locationSource() == LocationSource.MANUAL) {
            if (address == null) fields.put("address", "Required");
            else if (address.length() < MIN_ADDRESS_LENGTH) fields.put("address", "TooShort");
            if (hasLat || hasLng) fields.put("latitude", "NotAllowedForManual");
        } else {
            if (!hasLat) fields.put("latitude", "Required");
            if (!hasLng) fields.put("longitude", "Required");
            if (body.locationCapturedAt() == null) fields.put("locationCapturedAt", "Required");
            else if (body.locationCapturedAt().isAfter(Instant.now().plus(CLOCK_SKEW))) {
                fields.put("locationCapturedAt", "InFuture");
            }
        }
        if (!fields.isEmpty()) {
            throw ApiException.validation(fields);
        }
    }

    private static String clean(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
