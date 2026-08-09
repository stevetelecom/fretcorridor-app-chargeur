package com.fretcorridor.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configuration de securite de base.
 *
 * Principe : "deny by default". Rien n'est ouvert sans raison explicite.
 * - /actuator/health : ouvert, necessaire pour les sondes de sante (Docker,
 *   futur load balancer).
 * - /swagger-ui/**, /v3/api-docs/** : ouverts en attendant l'authentification
 *   JWT (Sprint 1), a fermer ou proteger en production si necessaire.
 * - Tout le reste : authentifie. Comme aucun module metier n'existe encore
 *   au Sprint 0, cela signifie simplement qu'il n'y a aucune route ouverte
 *   par accident.
 *
 * Le mot de passe est toujours hache avec BCrypt (jamais en clair, jamais
 * avec un algorithme faible type MD5/SHA1) - regle de securite non
 * negociable du guide ultime.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private static final String[] PUBLIC_ENDPOINTS = {
            "/actuator/health",
            "/swagger-ui/**",
            "/v3/api-docs/**"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // API stateless (JWT) : pas de session serveur, donc pas de CSRF
                // au sens classique (cookie de session). A revoir explicitement
                // si un flux base sur des cookies est introduit plus tard.
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .anyRequest().authenticated()
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // Cout 12 : bon compromis securite/performance en 2026, superieur au
        // defaut historique de 10.
        return new BCryptPasswordEncoder(12);
    }
}
