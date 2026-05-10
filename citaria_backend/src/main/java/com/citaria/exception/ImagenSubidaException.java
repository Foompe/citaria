package com.citaria.exception;

/**
 * Excepción lanzada cuando falla la subida de una imagen a Cloudinary
 * o la respuesta recibida no contiene la URL esperada.
 */
public class ImagenSubidaException extends RuntimeException {

    public ImagenSubidaException(String mensaje) {
        super(mensaje);
    }
}
