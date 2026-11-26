package com.urgences.api.sos.domain;

import java.time.Instant;

import com.urgences.api.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Version;

/** Une demande SOS. Son statut ne change que par {@link #moveTo}, qui applique les règles de {@link SosStatus}. */
@Entity
@Table(name = "sos_requests")
public class SosRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false, updatable = false)
    private User patient;

    @Column(name = "client_request_id", nullable = false, updatable = false, length = 36)
    private String clientRequestId;

    private Double latitude;

    private Double longitude;

    @Column(length = 255)
    private String address;

    @Enumerated(EnumType.STRING)
    @Column(name = "location_source", nullable = false, length = 20)
    private LocationSource locationSource;

    @Column(name = "location_accuracy")
    private Double locationAccuracy;

    @Column(name = "location_captured_at")
    private Instant locationCapturedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SosStatus status;

    @Column(name = "decision_message", length = 500)
    private String decisionMessage;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /** Verrou optimiste : deux décisions simultanées ne s'écrasent pas. */
    @Version
    private long version;

    protected SosRequest() {
    }

    public SosRequest(User patient, String clientRequestId, Double latitude, Double longitude, String address,
            LocationSource locationSource, Double locationAccuracy, Instant locationCapturedAt) {
        this.patient = patient;
        this.clientRequestId = clientRequestId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.locationSource = locationSource;
        this.locationAccuracy = locationAccuracy;
        this.locationCapturedAt = locationCapturedAt;
        this.status = SosStatus.PENDING;
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    /**
     * Applique une transition autorisée.
     *
     * @throws IllegalStateException si la transition n'est pas permise
     */
    public SosStatus moveTo(SosStatus target, String message) {
        if (!status.canMoveTo(target)) {
            throw new IllegalStateException(status + " -> " + target);
        }
        SosStatus old = status;
        status = target;
        if (message != null) decisionMessage = message;
        updatedAt = Instant.now();
        return old;
    }

    public Long getId() {
        return id;
    }

    public User getPatient() {
        return patient;
    }

    public String getClientRequestId() {
        return clientRequestId;
    }

    public Double getLatitude() {
        return latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public String getAddress() {
        return address;
    }

    public LocationSource getLocationSource() {
        return locationSource;
    }

    public Double getLocationAccuracy() {
        return locationAccuracy;
    }

    public Instant getLocationCapturedAt() {
        return locationCapturedAt;
    }

    public SosStatus getStatus() {
        return status;
    }

    public String getDecisionMessage() {
        return decisionMessage;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
