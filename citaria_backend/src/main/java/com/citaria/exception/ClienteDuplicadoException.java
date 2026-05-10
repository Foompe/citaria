package com.citaria.exception;

/**
 * Excepción lanzada cuando se detecta que ya existe un cliente con el mismo
 * email o DNI dentro de la misma organización.
 */
public class ClienteDuplicadoException extends RuntimeException {

    private final String campo;

    public ClienteDuplicadoException(String campo) {
        super("Ya existe un cliente con ese " + campo + " en esta organización");
        this.campo = campo;
    }

    public String getCampo() {
        return campo;
    }
}