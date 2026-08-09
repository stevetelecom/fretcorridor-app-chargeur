package com.fretcorridor.backend.auth.service;

import com.fretcorridor.backend.auth.dto.*;
import com.fretcorridor.backend.auth.entity.AccountLevel;
import com.fretcorridor.backend.auth.entity.RefreshToken;
import com.fretcorridor.backend.auth.entity.User;
import com.fretcorridor.backend.auth.repository.RefreshTokenRepository;
import com.fretcorridor.backend.auth.repository.UserRepository;
import com.fretcorridor.backend.common.exception.ApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

/**
 * Logique d'authentification : inscription, connexion, refresh, deconnexion.
 * Verrouillage temporaire apres 5 echecs consecutifs (protection brute
 * force basique, couverte par les tests du Sprint 1 - voir plan §4).
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final short MAX_FAILED_ATTEMPTS = 5;
    private static final Duration LOCK_DURATION = Duration.ofMinutes(15);

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Value("${app.jwt.refresh-expiration-ms}")
    private long refreshExpirationMs;

    @Transactional
    public TokenPairResponse register(RegisterRequest request) {
        if (userRepository.existsByPhoneNumber(request.phoneNumber())) {
            // Coherent avec le CDC (E4, UC-IDA-01) : ne jamais creer de
            // doublon d'identite, informer explicitement de la voie de
            // recuperation plutot qu'une erreur generique.
            throw new ApiException(HttpStatus.CONFLICT,
                    "Un compte existe deja avec ce numero. Connectez-vous ou utilisez la recuperation de compte.");
        }

        User user = User.builder()
                .accountType(request.accountType())
                .firstName(request.firstName().trim())
                .lastName(request.lastName().trim())
                .phoneNumber(request.phoneNumber())
                .pinHash(passwordEncoder.encode(request.pin()))
                .accountLevel(AccountLevel.NIVEAU_0)
                // Pas de verification SMS reelle en V1 (aucune passerelle
                // SMS integree a ce stade du plan) : la possession du
                // numero est assumee a l'inscription. A remplacer par un
                // vrai flux OTP des qu'un fournisseur SMS est integre.
                .phoneVerified(true)
                .build();

        user = userRepository.save(user);
        return issueTokenPair(user);
    }

    @Transactional
    public TokenPairResponse login(LoginRequest request) {
        User user = userRepository.findByPhoneNumber(request.phoneNumber())
                // Message volontairement identique a celui du PIN incorrect :
                // ne jamais reveler si un numero est enregistre (evite
                // l'enumeration de comptes).
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Numero ou code PIN incorrect"));

        if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(Instant.now())) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Compte temporairement bloque suite a plusieurs tentatives echouees. Reessayez plus tard.");
        }

        if (!passwordEncoder.matches(request.pin(), user.getPinHash())) {
            registerFailedAttempt(user);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Numero ou code PIN incorrect");
        }

        user.setFailedLoginAttempts((short) 0);
        user.setLockedUntil(null);
        userRepository.save(user);

        return issueTokenPair(user);
    }

    @Transactional
    public TokenPairResponse refresh(RefreshTokenRequest request) {
        String hash = TokenHasher.sha256(request.refreshToken());
        RefreshToken stored = refreshTokenRepository.findByTokenHashAndRevokedFalse(hash)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Refresh token invalide"));

        if (stored.getExpiresAt().isBefore(Instant.now())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Refresh token expire");
        }

        // Rotation : l'ancien token est revoque des sa premiere
        // utilisation, meme non expire - limite la fenetre d'exploitation
        // en cas de vol de token.
        stored.setRevoked(true);
        refreshTokenRepository.save(stored);

        User user = userRepository.findById(stored.getUserId())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Compte introuvable"));

        return issueTokenPair(user);
    }

    @Transactional
    public void logout(RefreshTokenRequest request) {
        String hash = TokenHasher.sha256(request.refreshToken());
        refreshTokenRepository.findByTokenHashAndRevokedFalse(hash)
                .ifPresent(token -> {
                    token.setRevoked(true);
                    refreshTokenRepository.save(token);
                });
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Compte introuvable"));
        return toProfile(user);
    }

    private void registerFailedAttempt(User user) {
        short attempts = (short) (user.getFailedLoginAttempts() + 1);
        user.setFailedLoginAttempts(attempts);
        if (attempts >= MAX_FAILED_ATTEMPTS) {
            user.setLockedUntil(Instant.now().plus(LOCK_DURATION));
        }
        userRepository.save(user);
    }

    private TokenPairResponse issueTokenPair(User user) {
        String accessToken = jwtService.generateAccessToken(
                user.getId(), user.getPhoneNumber(), user.getAccountLevel().name());

        String rawRefreshToken = TokenHasher.generateOpaqueToken();
        RefreshToken refreshToken = RefreshToken.builder()
                .userId(user.getId())
                .tokenHash(TokenHasher.sha256(rawRefreshToken))
                .expiresAt(Instant.now().plusMillis(refreshExpirationMs))
                .build();
        refreshTokenRepository.save(refreshToken);

        return new TokenPairResponse(
                accessToken, rawRefreshToken, jwtService.getAccessTokenExpirationMs(), toProfile(user));
    }

    private UserProfileResponse toProfile(User user) {
        return new UserProfileResponse(
                user.getId(), user.getAccountType(), user.getFirstName(),
                user.getLastName(), user.getPhoneNumber(), user.getAccountLevel());
    }
}
