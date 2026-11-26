package com.urgences.api.sos;

import java.util.Collection;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.urgences.api.sos.domain.SosRequest;
import com.urgences.api.sos.domain.SosStatus;

/** Les requêtes côté patient filtrent toujours par patientId : un patient ne voit jamais les demandes d'un autre. */
public interface SosRequestRepository extends JpaRepository<SosRequest, Long> {

    Optional<SosRequest> findByIdAndPatientId(Long id, Long patientId);

    Page<SosRequest> findByPatientId(Long patientId, Pageable pageable);

    Optional<SosRequest> findByPatientIdAndClientRequestId(Long patientId, String clientRequestId);

    Optional<SosRequest> findFirstByPatientIdAndStatusInOrderByCreatedAtDesc(Long patientId,
            Collection<SosStatus> statuses);

    @EntityGraph(attributePaths = "patient")
    Page<SosRequest> findByStatusIn(Collection<SosStatus> statuses, Pageable pageable);

    @EntityGraph(attributePaths = "patient")
    Optional<SosRequest> findWithPatientById(Long id);
}
