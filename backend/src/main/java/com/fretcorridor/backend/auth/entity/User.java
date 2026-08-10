package com.fretcorridor.backend.auth.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Compte utilisateur "chargeur" (particulier ou entreprise).
 *
 * Le PIN n'est jamais stocke ni logge en clair : seul son hachage BCrypt
 * (pinHash) est persiste, via le PasswordEncoder defini dans SecurityConfig.
 *
 * failedLoginAttempts / lockedUntil implementent une protection basique
 * contre le brute force (verrouillage temporaire apres 5 echecs, voir
 * AuthService) - couvert par les tests prevus au Sprint 1 du plan.
 */
@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_type", nullable = false, length = 20)
    private AccountType accountType;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;
    // Requise uniquement pour un compte ENTREPRISE (verifie dans
    // AuthService.register), nulle pour un PARTICULIER - voir migration
    // V10__add_company_name_to_users.sql.
    @Column(name = "company_name", length = 200)
    private String companyName;

    @Column(name = "phone_number", nullable = false, unique = true, length = 20)
    private String phoneNumber;

    @Column(name = "pin_hash", nullable = false, length = 100)
    private String pinHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_level", nullable = false, length = 20)
    @Builder.Default
    private AccountLevel accountLevel = AccountLevel.NIVEAU_0;

    @Column(name = "phone_verified", nullable = false)
    @Builder.Default
    private boolean phoneVerified = false;

    @Column(name = "failed_login_attempts", nullable = false)
    @Builder.Default
    private short failedLoginAttempts = 0;

    @Column(name = "locked_until")
    private Instant lockedUntil;

    // Sprint 5 (notification, rattrape) : token FCM du dernier appareil
    // connu - voir NotificationService pour l'envoi et DeviceTokenController
    // pour l'enregistrement.
    @Column(name = "fcm_token")
    private String fcmToken;

    @Column(name = "fcm_token_updated_at")
    private Instant fcmTokenUpdatedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
