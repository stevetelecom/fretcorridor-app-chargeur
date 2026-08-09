package com.fretcorridor.backend.auth.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

/**
 * Genere et valide les access tokens JWT (courte duree). Les refresh
 * tokens ne sont PAS des JWT : voir TokenHasher - un refresh token n'a pas
 * besoin d'etre auto-porteur, et un token opaque revocable en base est
 * plus sur pour une duree de vie longue (7 jours par defaut).
 */
@Service
public class JwtService {

    private final SecretKey signingKey;
    private final long accessTokenExpirationMs;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.expiration-ms}") long accessTokenExpirationMs) {
        // JWT_SECRET dans .env doit faire au moins 256 bits
        // (genere avec : openssl rand -base64 64).
        this.signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpirationMs = accessTokenExpirationMs;
    }

    /**
     * Le JWT ne contient jamais de donnee sensible (jamais le PIN, jamais
     * le hash) - uniquement l'id utilisateur et le niveau de compte, a
     * titre indicatif cote client. Le backend revalide toujours cote
     * serveur avant toute action sensible.
     */
    public String generateAccessToken(UUID userId, String phoneNumber, String accountLevel) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + accessTokenExpirationMs);

        return Jwts.builder()
                .subject(userId.toString())
                .claim("phone", phoneNumber)
                .claim("accountLevel", accountLevel)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(signingKey)
                .compact();
    }

    /** Leve une exception (expiration, signature invalide, etc.) geree par JwtAuthenticationFilter. */
    public Claims parseAndValidate(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public long getAccessTokenExpirationMs() {
        return accessTokenExpirationMs;
    }
}
