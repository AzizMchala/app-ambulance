package com.urgences.api;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import com.jayway.jsonpath.JsonPath;
import com.urgences.api.user.Role;
import com.urgences.api.user.User;
import com.urgences.api.user.UserRepository;

/** Parcours complets du module E2 contre un vrai MySQL : création, suivi, historique, droits, décisions. */
@IntegrationTest
class SosIntegrationTest {

    private static final AtomicInteger SEQ = new AtomicInteger();

    @Autowired
    MockMvc mvc;

    @Autowired
    UserRepository users;

    @Autowired
    PasswordEncoder passwords;

    // ---- outils ----

    private String registerPatient() throws Exception {
        String email = "patient" + SEQ.incrementAndGet() + "-" + UUID.randomUUID() + "@test.tn";
        String body = mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content("{\"fullName\":\"Aziz Test\",\"email\":\"" + email + "\",\"password\":\"motdepasse1\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.user.role").value("PATIENT"))
            .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.accessToken");
    }

    private String responderToken() throws Exception {
        String email = "secours" + SEQ.incrementAndGet() + "@test.tn";
        users.save(new User("Régulation", email, passwords.encode("motdepasse1"), Role.RESPONDER));
        String body = mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"" + email + "\",\"password\":\"motdepasse1\"}"))
            .andExpect(status().isOk())
            .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.accessToken");
    }

    private static MockHttpServletRequestBuilder auth(MockHttpServletRequestBuilder b, String token) {
        return b.header("Authorization", "Bearer " + token);
    }

    private static String gpsBody(String clientId) {
        return "{\"clientRequestId\":\"" + clientId + "\",\"locationSource\":\"GPS\",\"latitude\":36.80651,"
            + "\"longitude\":10.18152,\"locationAccuracy\":12.5,\"locationCapturedAt\":\"" + Instant.now() + "\"}";
    }

    private ResultActions createSos(String token, String json) throws Exception {
        return mvc.perform(auth(post("/api/sos"), token).contentType(MediaType.APPLICATION_JSON).content(json));
    }

    private long createdId(String token) throws Exception {
        String body = createSos(token, gpsBody(UUID.randomUUID().toString()))
            .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(body, "$.id")).longValue();
    }

    // ---- création ----

    @Test
    void createsGpsRequestAndRecordsHistory() throws Exception {
        String token = registerPatient();
        createSos(token, gpsBody(UUID.randomUUID().toString()))
            .andExpect(status().isCreated())
            .andExpect(header().exists("Location"))
            .andExpect(jsonPath("$.status").value("PENDING"))
            .andExpect(jsonPath("$.locationSource").value("GPS"))
            .andExpect(jsonPath("$.latitude").value(36.80651))
            .andExpect(jsonPath("$.decisionMessage").value(nullValue()));

        long id = ((Number) JsonPath.read(mvc.perform(auth(get("/api/sos"), token))
            .andExpect(jsonPath("$.items", hasSize(1)))
            .andExpect(jsonPath("$.totalElements").value(1))
            .andReturn().getResponse().getContentAsString(), "$.items[0].id")).longValue();

        mvc.perform(auth(get("/api/sos/" + id + "/history"), token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$", hasSize(1)))
            .andExpect(jsonPath("$[0].oldStatus").value(nullValue()))
            .andExpect(jsonPath("$[0].newStatus").value("PENDING"));
    }

    @Test
    void sameClientRequestIdIsIdempotent() throws Exception {
        String token = registerPatient();
        String clientId = UUID.randomUUID().toString();
        String first = createSos(token, gpsBody(clientId)).andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();
        createSos(token, gpsBody(clientId))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(((Number) JsonPath.read(first, "$.id")).longValue()));
        mvc.perform(auth(get("/api/sos"), token)).andExpect(jsonPath("$.totalElements").value(1));
    }

    @Test
    void refusesSecondActiveRequest() throws Exception {
        String token = registerPatient();
        long id = createdId(token);
        createSos(token, gpsBody(UUID.randomUUID().toString()))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.code").value("SOS_ALREADY_ACTIVE"))
            .andExpect(jsonPath("$.details.activeRequestId").value(id));
    }

    @Test
    void manualRequestNeedsAnAddress() throws Exception {
        String token = registerPatient();
        createSos(token, "{\"clientRequestId\":\"" + UUID.randomUUID() + "\",\"locationSource\":\"MANUAL\"}")
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
            .andExpect(jsonPath("$.fields.address").value("Required"));

        createSos(token, "{\"clientRequestId\":\"" + UUID.randomUUID()
                + "\",\"locationSource\":\"MANUAL\",\"address\":\"12 rue de Marseille, Tunis\"}")
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.latitude").value(nullValue()))
            .andExpect(jsonPath("$.address").value("12 rue de Marseille, Tunis"));
    }

    @Test
    void gpsRequestNeedsCoordinatesAndValidRanges() throws Exception {
        String token = registerPatient();
        createSos(token, "{\"clientRequestId\":\"" + UUID.randomUUID() + "\",\"locationSource\":\"GPS\"}")
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fields.latitude").value("Required"));
        createSos(token, "{\"clientRequestId\":\"" + UUID.randomUUID()
                + "\",\"locationSource\":\"GPS\",\"latitude\":95,\"longitude\":10,\"locationCapturedAt\":\""
                + Instant.now() + "\"}")
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fields.latitude").exists());
        createSos(token, "{\"clientRequestId\":\"pas-un-uuid\",\"locationSource\":\"GPS\"}")
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fields.clientRequestId").exists());
    }

    // ---- droits ----

    @Test
    void patientNeverSeesAnotherPatientsRequest() throws Exception {
        String alice = registerPatient();
        String bob = registerPatient();
        long id = createdId(alice);

        mvc.perform(auth(get("/api/sos/" + id), bob)).andExpect(status().isNotFound())
            .andExpect(jsonPath("$.code").value("SOS_NOT_FOUND"));
        mvc.perform(auth(get("/api/sos/" + id + "/status"), bob)).andExpect(status().isNotFound());
        mvc.perform(auth(get("/api/sos/" + id + "/history"), bob)).andExpect(status().isNotFound());
        mvc.perform(auth(post("/api/sos/" + id + "/cancel"), bob)).andExpect(status().isNotFound());
        mvc.perform(auth(get("/api/sos"), bob)).andExpect(jsonPath("$.totalElements").value(0));
    }

    @Test
    void requiresAuthenticationAndRoles() throws Exception {
        mvc.perform(get("/api/sos")).andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
        mvc.perform(get("/api/sos").header("Authorization", "Bearer faux.jeton.signe"))
            .andExpect(status().isUnauthorized());

        String patient = registerPatient();
        mvc.perform(auth(get("/api/responder/sos"), patient)).andExpect(status().isForbidden())
            .andExpect(jsonPath("$.code").value("FORBIDDEN"));

        String responder = responderToken();
        mvc.perform(auth(get("/api/sos"), responder)).andExpect(status().isForbidden());
    }

    @Test
    void wrongPasswordIsRejected() throws Exception {
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"inconnu@test.tn\",\"password\":\"motdepasse1\"}"))
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    // ---- suivi et décisions ----

    @Test
    void responderDecisionIsVisibleToPatientWithHistory() throws Exception {
        String patient = registerPatient();
        String responder = responderToken();
        long id = createdId(patient);

        mvc.perform(auth(get("/api/responder/sos"), responder)).andExpect(status().isOk());

        mvc.perform(auth(patch("/api/responder/sos/" + id + "/status"), responder)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"status\":\"ACCEPTED\",\"message\":\"Une ambulance part vers vous.\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.request.status").value("ACCEPTED"));

        mvc.perform(auth(get("/api/sos/" + id + "/status"), patient))
            .andExpect(jsonPath("$.status").value("ACCEPTED"))
            .andExpect(jsonPath("$.decisionMessage").value("Une ambulance part vers vous."));

        mvc.perform(auth(get("/api/sos/" + id + "/history"), patient))
            .andExpect(jsonPath("$", hasSize(2)))
            .andExpect(jsonPath("$[1].oldStatus").value("PENDING"))
            .andExpect(jsonPath("$[1].newStatus").value("ACCEPTED"));

        // Décidée : le patient ne peut plus l'annuler.
        mvc.perform(auth(post("/api/sos/" + id + "/cancel"), patient))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        // Transition interdite : ACCEPTED -> PENDING.
        mvc.perform(auth(patch("/api/responder/sos/" + id + "/status"), responder)
                .contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"PENDING\"}"))
            .andExpect(status().isConflict());
    }

    @Test
    void hospitalFollowsTheFullLifecycle() throws Exception {
        String patient = registerPatient();
        String hospital = responderToken();
        long id = createdId(patient);

        mvc.perform(auth(get("/api/responder/sos/" + id), hospital))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.patientName").value("Aziz Test"))
            .andExpect(jsonPath("$.request.locationSource").value("GPS"));
        mvc.perform(auth(get("/api/responder/sos/" + id), patient)).andExpect(status().isForbidden());

        for (String next : new String[] {"ACCEPTED", "IN_PROGRESS", "COMPLETED"}) {
            mvc.perform(auth(patch("/api/responder/sos/" + id + "/status"), hospital)
                    .contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"" + next + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.request.status").value(next));
        }

        mvc.perform(auth(get("/api/responder/sos/" + id + "/history"), hospital))
            .andExpect(jsonPath("$", hasSize(4)))
            .andExpect(jsonPath("$[3].newStatus").value("COMPLETED"));

        // Terminée : elle quitte la file active et apparaît dans les clôturées.
        String active = mvc.perform(auth(get("/api/responder/sos?size=50"), hospital))
            .andReturn().getResponse().getContentAsString();
        org.assertj.core.api.Assertions.assertThat(active).doesNotContain("\"id\":" + id + ",");
        mvc.perform(auth(get("/api/responder/sos?status=COMPLETED&size=1"), hospital))
            .andExpect(jsonPath("$.items[0].request.id").value(id));
    }

    @Test
    void rejectionRequiresAMessage() throws Exception {
        String patient = registerPatient();
        String responder = responderToken();
        long id = createdId(patient);
        mvc.perform(auth(patch("/api/responder/sos/" + id + "/status"), responder)
                .contentType(MediaType.APPLICATION_JSON).content("{\"status\":\"REJECTED\"}"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.fields.message").value("RequiredForRejection"));
    }

    @Test
    void patientCancelsPendingRequestThenCanSendAgain() throws Exception {
        String token = registerPatient();
        long id = createdId(token);
        mvc.perform(auth(post("/api/sos/" + id + "/cancel"), token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("CANCELLED"));
        mvc.perform(auth(get("/api/sos/" + id + "/history"), token)).andExpect(jsonPath("$", hasSize(2)));
        createdId(token);
    }

    @Test
    void paginatesNewestFirst() throws Exception {
        String token = registerPatient();
        long first = createdId(token);
        mvc.perform(auth(post("/api/sos/" + first + "/cancel"), token)).andExpect(status().isOk());
        long second = createdId(token);

        mvc.perform(auth(get("/api/sos?page=0&size=1"), token))
            .andExpect(jsonPath("$.items[0].id").value(second))
            .andExpect(jsonPath("$.totalPages").value(2));
        mvc.perform(auth(get("/api/sos?page=1&size=1"), token))
            .andExpect(jsonPath("$.items[0].id").value(first));
        mvc.perform(auth(get("/api/sos?size=500"), token)).andExpect(status().isBadRequest());
    }
}
