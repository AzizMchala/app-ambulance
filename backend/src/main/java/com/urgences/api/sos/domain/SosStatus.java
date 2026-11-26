package com.urgences.api.sos.domain;

import java.util.EnumSet;
import java.util.Set;

/**
 * Cycle de vie d'une demande SOS. Les transitions autorisées sont définies ici et nulle part ailleurs.
 *
 * <pre>
 * PENDING ──► ACCEPTED ──► IN_PROGRESS ──► COMPLETED
 *    │            │  └─────────────────────►┘
 *    ├──► REJECTED └──► CANCELLED
 *    └──► CANCELLED
 * </pre>
 */
public enum SosStatus {
    PENDING,
    ACCEPTED,
    IN_PROGRESS,
    COMPLETED,
    REJECTED,
    CANCELLED;

    public Set<SosStatus> next() {
        return switch (this) {
            case PENDING -> EnumSet.of(ACCEPTED, REJECTED, CANCELLED);
            case ACCEPTED -> EnumSet.of(IN_PROGRESS, COMPLETED, CANCELLED);
            case IN_PROGRESS -> EnumSet.of(COMPLETED);
            case COMPLETED, REJECTED, CANCELLED -> EnumSet.noneOf(SosStatus.class);
        };
    }

    public boolean canMoveTo(SosStatus target) {
        return next().contains(target);
    }

    /** La demande attend encore une suite : un patient ne peut en avoir qu'une à la fois. */
    public boolean isActive() {
        return this == PENDING || this == ACCEPTED || this == IN_PROGRESS;
    }

    public static Set<SosStatus> active() {
        return EnumSet.of(PENDING, ACCEPTED, IN_PROGRESS);
    }
}
