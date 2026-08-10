package com.fretcorridor.backend.notification.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Envoie une notification push a un utilisateur via son token FCM.
 * Volontairement tolerant aux pannes : un echec d'envoi (token expire,
 * Firebase indisponible, SDK non initialise) ne doit JAMAIS faire echouer
 * l'action metier qui a declenche la notification (ex. un paiement reussi
 * doit rester reussi meme si le push echoue) - voir l'appel depuis
 * ShipmentTrackingService, toujours apres la transaction metier.
 */
@Service
@Slf4j
public class NotificationService {

    public void sendToToken(String fcmToken, String title, String body) {
        if (fcmToken == null || fcmToken.isBlank()) {
            return; // utilisateur sans token enregistre (jamais connecte depuis l'app, ou refus des permissions)
        }
        if (FirebaseApp.getApps().isEmpty()) {
            log.warn("Notification non envoyee : Firebase Admin SDK non initialise");
            return;
        }

        Message message = Message.builder()
                .setToken(fcmToken)
                .setNotification(Notification.builder().setTitle(title).setBody(body).build())
                .build();

        try {
            FirebaseMessaging.getInstance().send(message);
        } catch (FirebaseMessagingException e) {
            // Log et on continue : voir la javadoc de la classe.
            log.warn("Echec d'envoi de la notification push (token possiblement expire) : {}", e.getMessage());
        }
    }
}
