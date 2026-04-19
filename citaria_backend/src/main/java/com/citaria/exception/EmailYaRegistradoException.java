package com.citaria.exception;

/**
 * Excepción lanzada cuando se intenta registrar un email
 * que ya tiene un usuario asociado en el sistema.
 * Resulta en una respuesta HTTP 409 Conflict.
 */
public class EmailYaRegistradoException extends RuntimeException {

    public EmailYaRegistradoException(String mensaje) {
        super(mensaje);
    }
}