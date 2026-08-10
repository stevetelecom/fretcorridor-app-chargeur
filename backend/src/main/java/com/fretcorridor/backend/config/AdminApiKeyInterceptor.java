package com.fretcorridor.backend.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Protege /api/admin/** par une cle statique (header X-Admin-Api-Key),
 * totalement separee du JWT chargeur. Ce n'est pas un role utilisateur :
 * c'est un outil interne (remplace l'app chauffeur hors perimetre solo),
 * jamais expose au mobile chargeur. Comparaison en temps constant pour
 * eviter une attaque par timing sur la cle.
 */
@Component
public class AdminApiKeyInterceptor implements HandlerInterceptor {

    private final String expectedApiKey;

    public AdminApiKeyInterceptor(@Value("${app.admin.api-key}") String expectedApiKey) {
        this.expectedApiKey = expectedApiKey;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String provided = request.getHeader("X-Admin-Api-Key");
        if (provided == null || !constantTimeEquals(provided, expectedApiKey)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Cle admin invalide ou absente");
            return false;
        }
        return true;
    }

    private boolean constantTimeEquals(String a, String b) {
        return MessageDigest.isEqual(
                a.getBytes(StandardCharsets.UTF_8),
                b.getBytes(StandardCharsets.UTF_8));
    }
}
