package com.urgences.api.user;

public enum Role {
    /** Patient : envoie des SOS et consulte uniquement les siens. */
    PATIENT,
    /** Personnel des secours (modules E3/E6) : décide et fait évoluer le statut des demandes. */
    RESPONDER
}
