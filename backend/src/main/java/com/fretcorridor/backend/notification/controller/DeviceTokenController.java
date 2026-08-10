package com.fretcorridor.backend.notification.controller;

import com.fretcorridor.backend.auth.repository.UserRepository;
import com.fretcorridor.backend.common.exception.ApiException;
import com.fretcorridor.backend.notification.dto.DeviceTokenRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.time.Instant;
import java.util.UUID;

// Meme pattern que ShipmentController/TrackingController : Principal.getName()
// = UUID de l'utilisateur authentifie. Appele par le mobile juste apres le
// login et a chaque rafraichissement de token FCM (Firebase peut en emettre
// un nouveau a tout moment).
@RestController
@RequestMapping("/api/me")
@RequiredArgsConstructor
public class DeviceTokenController {

    private final UserRepository userRepository;

    @PostMapping("/device-token")
    @Transactional
    public ResponseEntity<Void> registerToken(Principal principal, @Valid @RequestBody DeviceTokenRequest request) {
        var user = userRepository.findById(UUID.fromString(principal.getName()))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));
        user.setFcmToken(request.fcmToken());
        user.setFcmTokenUpdatedAt(Instant.now());
        userRepository.save(user);
        return ResponseEntity.noContent().build();
    }
}
