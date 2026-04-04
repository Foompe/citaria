package com.citaria.exception;

/**
 * Excepción lanzada cuando un recurso solicitado no existe.
 * Resulta en una respuesta HTTP 404.
 */
public class RecursoNoEncontradoException extends RuntimeException {

    public RecursoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}