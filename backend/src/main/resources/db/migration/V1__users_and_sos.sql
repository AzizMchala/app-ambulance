-- Schéma initial : comptes partagés + module E2 (SOS et historique).
-- Toutes les dates sont en UTC (hibernate.jdbc.time_zone = UTC).

CREATE TABLE users (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(120) NOT NULL,
    email         VARCHAR(190) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    role          VARCHAR(20)  NOT NULL,
    created_at    DATETIME(6)  NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_role CHECK (role IN ('PATIENT', 'RESPONDER'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE sos_requests (
    id                   BIGINT       NOT NULL AUTO_INCREMENT,
    patient_id           BIGINT       NOT NULL,
    -- Clé d'idempotence générée par le téléphone : une alerte renvoyée après une coupure n'est créée qu'une fois.
    client_request_id    CHAR(36)     NOT NULL,
    latitude             DOUBLE       NULL,
    longitude            DOUBLE       NULL,
    address              VARCHAR(255) NULL,
    location_source      VARCHAR(20)  NOT NULL,
    location_accuracy    DOUBLE       NULL,
    location_captured_at DATETIME(6)  NULL,
    status               VARCHAR(20)  NOT NULL,
    decision_message     VARCHAR(500) NULL,
    created_at           DATETIME(6)  NOT NULL,
    updated_at           DATETIME(6)  NOT NULL,
    version              BIGINT       NOT NULL DEFAULT 0,
    CONSTRAINT pk_sos_requests PRIMARY KEY (id),
    -- Suppression d'un compte = suppression de ses alertes et de leurs positions (minimisation des données).
    CONSTRAINT fk_sos_requests_patient FOREIGN KEY (patient_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT uq_sos_requests_client UNIQUE (patient_id, client_request_id),
    CONSTRAINT ck_sos_status CHECK (status IN ('PENDING', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT ck_sos_location_source CHECK (location_source IN ('GPS', 'LAST_KNOWN', 'MANUAL')),
    CONSTRAINT ck_sos_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT ck_sos_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    -- Latitude et longitude vont ensemble.
    CONSTRAINT ck_sos_coordinates_pair CHECK ((latitude IS NULL) = (longitude IS NULL)),
    -- Une alerte a toujours une localisation : des coordonnées ou une adresse.
    CONSTRAINT ck_sos_has_location CHECK (latitude IS NOT NULL OR address IS NOT NULL),
    CONSTRAINT ck_sos_accuracy CHECK (location_accuracy IS NULL OR location_accuracy >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE INDEX ix_sos_requests_patient_created ON sos_requests (patient_id, created_at DESC, id DESC);
CREATE INDEX ix_sos_requests_status_created ON sos_requests (status, created_at);

CREATE TABLE sos_history (
    id                 BIGINT       NOT NULL AUTO_INCREMENT,
    sos_request_id     BIGINT       NOT NULL,
    old_status         VARCHAR(20)  NULL,
    new_status         VARCHAR(20)  NOT NULL,
    description        VARCHAR(500) NULL,
    changed_by_user_id BIGINT       NULL,
    created_at         DATETIME(6)  NOT NULL,
    CONSTRAINT pk_sos_history PRIMARY KEY (id),
    CONSTRAINT fk_sos_history_request FOREIGN KEY (sos_request_id) REFERENCES sos_requests (id) ON DELETE CASCADE,
    CONSTRAINT fk_sos_history_user FOREIGN KEY (changed_by_user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT ck_sos_history_new CHECK (new_status IN ('PENDING', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT ck_sos_history_old CHECK (old_status IS NULL OR old_status IN ('PENDING', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE INDEX ix_sos_history_request_created ON sos_history (sos_request_id, created_at, id);
