package com.urgences.api.sos;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.urgences.api.sos.domain.SosHistory;

public interface SosHistoryRepository extends JpaRepository<SosHistory, Long> {

    List<SosHistory> findBySosRequestIdOrderByCreatedAtAscIdAsc(Long sosRequestId);
}
