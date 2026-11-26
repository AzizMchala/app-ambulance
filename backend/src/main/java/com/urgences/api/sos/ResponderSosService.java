package com.urgences.api.sos;

import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.urgences.api.common.ApiException;
import com.urgences.api.common.PageResponse;
import com.urgences.api.sos.domain.SosHistory;
import com.urgences.api.sos.domain.SosRequest;
import com.urgences.api.sos.domain.SosStatus;
import com.urgences.api.sos.dto.SosDtos.ResponderSosResponse;
import com.urgences.api.sos.dto.SosDtos.SosHistoryResponse;
import com.urgences.api.sos.dto.SosDtos.UpdateSosStatusRequest;

/**
 * Côté secours : file des demandes et décisions. C'est la seule source des acceptations,
 * refus et changements de statut que voit le patient. Utilisé par l'espace hôpital de l'application (E2) ; E3/E6 pourront s'y brancher.
 */
@Service
public class ResponderSosService {

    private final SosRequestRepository requests;
    private final SosHistoryRepository history;

    public ResponderSosService(SosRequestRepository requests, SosHistoryRepository history) {
        this.requests = requests;
        this.history = history;
    }

    @Transactional(readOnly = true)
    public PageResponse<ResponderSosResponse> list(Set<SosStatus> statuses, int page, int size) {
        if (page < 0 || size < 1 || size > SosService.MAX_PAGE_SIZE) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "INVALID_PARAMETER", "Pagination invalide.");
        }
        Set<SosStatus> filter = statuses == null || statuses.isEmpty() ? SosStatus.active() : EnumSet.copyOf(statuses);
        // File active : la plus ancienne d'abord (premier arrivé, premier traité).
        // Demandes clôturées : les plus récentes d'abord (consultation).
        boolean queue = filter.stream().anyMatch(SosStatus::isActive);
        Sort sort = queue
            ? Sort.by(Sort.Order.asc("createdAt"), Sort.Order.asc("id"))
            : Sort.by(Sort.Order.desc("updatedAt"), Sort.Order.desc("id"));
        var pageable = PageRequest.of(page, size, sort);
        return PageResponse.of(requests.findByStatusIn(filter, pageable), ResponderSosResponse::of);
    }

    @Transactional(readOnly = true)
    public ResponderSosResponse get(long id) {
        return ResponderSosResponse.of(find(id));
    }

    @Transactional(readOnly = true)
    public List<SosHistoryResponse> history(long id) {
        find(id);
        return history.findBySosRequestIdOrderByCreatedAtAscIdAsc(id).stream().map(SosHistoryResponse::of).toList();
    }

    private SosRequest find(long id) {
        return requests.findWithPatientById(id)
            .orElseThrow(() -> ApiException.notFound("SOS_NOT_FOUND", "Demande introuvable."));
    }

    @Transactional
    public ResponderSosResponse updateStatus(long responderId, long id, UpdateSosStatusRequest body) {
        var request = find(id);
        String message = body.message() == null || body.message().isBlank() ? null : body.message().trim();
        if (body.status() == SosStatus.REJECTED && message == null) {
            throw ApiException.validation(Map.of("message", "RequiredForRejection"));
        }
        if (!request.getStatus().canMoveTo(body.status())) {
            throw new ApiException(HttpStatus.CONFLICT, "INVALID_STATUS_TRANSITION",
                "Transition impossible : " + request.getStatus() + " vers " + body.status() + ".",
                Map.of("currentStatus", request.getStatus().name()));
        }
        SosStatus old = request.moveTo(body.status(), message);
        history.save(new SosHistory(id, old, body.status(),
            message != null ? message : "Statut mis à jour par les secours.", responderId));
        return ResponderSosResponse.of(requests.saveAndFlush(request));
    }
}
