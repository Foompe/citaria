package com.citaria.exception;

/**
 * Excepción lanzada cuando se intenta registrar un email
 * que ya tiene un usuario asociado en el sistema.
 */
public class EmailYaRegistradoException extends RuntimeException {

    public EmailYaRegistradoException(String mensaje) {
        super(mensaje);
    }

}