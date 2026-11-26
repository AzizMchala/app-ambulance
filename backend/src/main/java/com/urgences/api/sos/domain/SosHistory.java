package com.urgences.api.sos.domain;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** Trace immuable d'un changement de statut (création comprise, avec {@code oldStatus = null}). */
@Entity
@Table(name = "sos_history")
public class SosHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "sos_request_id", nullable = false, updatable = false)
    private Long sosRequestId;

    @Enumerated(EnumType.STRING)
    @Column(name = "old_status", updatable = false, length = 20)
    private SosStatus oldStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "new_status", nullable = false, updatable = false, length = 20)
    private SosStatus newStatus;

    @Column(updatable = false, length = 500)
    private String description;

    @Column(name = "changed_by_user_id", updatable = false)
    private Long changedByUserId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected SosHistory() {
    }

    public SosHistory(Long sosRequestId, SosStatus oldStatus, SosStatus newStatus, String description,
            Long changedByUserId) {
        this.sosRequestId = sosRequestId;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.description = description;
        this.changedByUserId = changedByUserId;
        this.createdAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public Long getSosRequestId() {
        return sosRequestId;
    }

    public SosStatus getOldStatus() {
        return oldStatus;
    }

    public SosStatus getNewStatus() {
        return newStatus;
    }

    public String getDescription() {
        return description;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
