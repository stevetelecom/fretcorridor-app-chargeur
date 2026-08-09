package com.fretcorridor.backend.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Exception metier generique portant le statut HTTP a renvoyer. Toute
 * erreur previsible (regle metier violee, conflit, non trouve) passe par
 * ici plutot que par une RuntimeException brute, pour ne jamais laisser
 * fuir de detail d'implementation au client.
 */
public class ApiException extends RuntimeException {

    private final HttpStatus status;

    public ApiException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
