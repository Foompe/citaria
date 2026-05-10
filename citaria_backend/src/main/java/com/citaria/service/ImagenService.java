package com.citaria.service;

import com.citaria.exception.ImagenSubidaException;
import org.springframework.web.multipart.MultipartFile;

/**
 * Servicio de subida de imágenes.
 */
public interface ImagenService {

    /**
     * Sube el archivo indicado a Cloudinary y devuelve la URL pública resultante.
     *
     * @param archivo archivo de imagen recibido en la petición
     * @return URL pública de la imagen subida
     * @throws ImagenSubidaException si la subida falla o Cloudinary devuelve una respuesta inesperada
     */
    String subirImagen(MultipartFile archivo) throws ImagenSubidaException;

}