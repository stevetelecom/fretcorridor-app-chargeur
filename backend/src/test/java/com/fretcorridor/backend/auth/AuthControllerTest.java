package com.fretcorridor.backend.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Couvre les criteres du Sprint 1 (plan §4) : validation stricte des DTO,
 * non-duplication de compte, verrouillage brute force. PostgreSQL reel via
 * Testcontainers (pas H2) pour rester fidele au comportement de prod.
 */
@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerTest {

    @Container
    static PostgreSQLContainer<?> postgres =
            new PostgreSQLContainer<>("postgis/postgis:16-3.4-alpine");

    @DynamicPropertySource
    static void configure(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @Test
    void register_avecPinInvalide_renvoie400() throws Exception {
        var body = Map.of(
                "accountType", "PARTICULIER",
                "firstName", "Olivier",
                "lastName", "Mekontso",
                "phoneNumber", "+237654862989",
                "pin", "12" // trop court : rejete par @Pattern
        );

        mockMvc.perform(post("/api/auth/register")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void register_puisMemeNumero_renvoie409() throws Exception {
        var body = Map.of(
                "accountType", "PARTICULIER",
                "firstName", "Olivier",
                "lastName", "Mekontso",
                "phoneNumber", "+237600000001",
                "pin", "4321"
        );
        String json = objectMapper.writeValueAsString(body);

        mockMvc.perform(post("/api/auth/register").contentType("application/json").content(json))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/auth/register").contentType("application/json").content(json))
                .andExpect(status().isConflict());
    }

    @Test
    void login_cinqEchecs_verrouilleLeCompte() throws Exception {
        var register = Map.of(
                "accountType", "PARTICULIER",
                "firstName", "Test",
                "lastName", "Bruteforce",
                "phoneNumber", "+237600000002",
                "pin", "1234"
        );
        mockMvc.perform(post("/api/auth/register")
                .contentType("application/json")
                .content(objectMapper.writeValueAsString(register)))
                .andExpect(status().isCreated());

        var wrongLogin = Map.of("phoneNumber", "+237600000002", "pin", "9999");
        String json = objectMapper.writeValueAsString(wrongLogin);

        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/auth/login").contentType("application/json").content(json))
                    .andExpect(status().isUnauthorized());
        }

        // 6e tentative : compte verrouille, meme avec le bon PIN cette fois
        var correctLogin = Map.of("phoneNumber", "+237600000002", "pin", "1234");
        mockMvc.perform(post("/api/auth/login")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(correctLogin)))
                .andExpect(status().isTooManyRequests());
    }
}
