package com.fretcorridor.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

/**
 * Initialise le SDK Firebase Admin une seule fois au demarrage, a partir
 * du fichier de compte de service (jamais commite, voir .gitignore et
 * docker-compose.yml pour le montage en volume). Si le fichier est absent
 * ou invalide, on logge une erreur claire mais on NE bloque PAS le
 * demarrage du backend - les notifications sont une fonctionnalite annexe,
 * pas un pre-requis pour que l'app reste utilisable (fail-soft assume).
 */
@Configuration
@Slf4j
public class FirebaseConfig {

    private final String credentialsPath;

    public FirebaseConfig(@Value("${app.firebase.credentials-path}") String credentialsPath) {
        this.credentialsPath = credentialsPath;
    }

    @PostConstruct
    public void init() {
        if (!FirebaseApp.getApps().isEmpty()) {
            return; // deja initialise (utile pour les tests qui rechargent le contexte)
        }
        try (FileInputStream serviceAccount = new FileInputStream(credentialsPath)) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
            FirebaseApp.initializeApp(options);
            log.info("Firebase Admin SDK initialise avec succes ({})", credentialsPath);
        } catch (IOException e) {
            log.error("Impossible d'initialiser Firebase Admin SDK (fichier '{}' introuvable ou invalide) "
                    + "- les notifications push seront desactivees, le reste de l'application continue de fonctionner.",
                    credentialsPath, e);
        }
    }
}
