package com.citaria.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.citaria.exception.ImagenSubidaException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.util.Map;

/**
 * Servicio de subida de imágenes de Cloudinary.
 */
@Service
public class CloudinaryImagenServiceImpl implements ImagenService {

    private static final String CLAVE_SECURE_URL = "secure_url";
    private static final String MENSAJE_ERROR_SUBIDA = "No se pudo subir la imagen a Cloudinary";
    private static final String MENSAJE_RESPUESTA_INVALIDA =
            "Cloudinary no devolvió una URL segura para la imagen";

    private final Cloudinary cloudinary;

    /**
     * Construye el servicio con el cliente de Cloudinary configurado.
     *
     * @param cloudinary cliente de Cloudinary configurado
     */
    @Autowired
    public CloudinaryImagenServiceImpl(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    /**
     * Sube el archivo indicado a Cloudinary y devuelve la URL pública segura.
     *
     * @param archivo archivo de imagen recibido en la petición
     * @return URL pública segura devuelta por Cloudinary
     * @throws ImagenSubidaException si la subida falla o la respuesta no contiene la URL esperada
     */
    @Override
    @SuppressWarnings("unchecked")
    public String subirImagen(MultipartFile archivo) throws ImagenSubidaException {
        try {
            Map<String, String> resultado = (Map<String, String>) cloudinary.uploader()
                    .upload(archivo.getBytes(), ObjectUtils.emptyMap());
            if (resultado == null || !resultado.containsKey(CLAVE_SECURE_URL)
                    || resultado.get(CLAVE_SECURE_URL) == null) {
                throw new ImagenSubidaException(MENSAJE_RESPUESTA_INVALIDA);
            }
            return resultado.get(CLAVE_SECURE_URL);
        } catch (ImagenSubidaException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new ImagenSubidaException(MENSAJE_ERROR_SUBIDA);
        }
    }
}
