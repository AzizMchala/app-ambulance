package com.urgences.api.sos.domain;

/** Origine de la localisation jointe à une demande. */
public enum LocationSource {
    /** Relevé GPS frais, pris au moment de la demande. */
    GPS,
    /** Dernière position connue du téléphone : ancienne, signalée comme telle aux secours. */
    LAST_KNOWN,
    /** Adresse saisie à la main, sans coordonnées. */
    MANUAL
}
