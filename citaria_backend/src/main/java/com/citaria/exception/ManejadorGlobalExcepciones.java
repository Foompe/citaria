package com.citaria.exception;

import com.citaria.dto.ErrorRespuestaDTO;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Manejador global de excepciones.
 * Centraliza el manejo de errores devolviendo respuestas consistentes y amigables.
 * Evita exponer información técnica sensible al cliente.
 */
@RestControllerAdvice
public class ManejadorGlobalExcepciones {

    /**
     * Maneja recursos no encontrados.
     * Devuelve 404 con mensaje descriptivo.
     */
    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarRecursoNoEncontrado(
            RecursoNoEncontradoException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(new ErrorRespuestaDTO(404, ex.getMessage()));
    }

    /**
     * Maneja errores de validación de campos.
     * Devuelve 400 con el primer error de validación encontrado.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarValidacion(
            MethodArgumentNotValidException ex) {
        String mensaje = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .findFirst()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .orElse("Error de validación");
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(new ErrorRespuestaDTO(400, mensaje));
    }

    /**
     * Maneja cualquier excepción no controlada.
     * Devuelve 500 con mensaje genérico sin exponer información técnica.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarExcepcionGeneral(Exception ex) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorRespuestaDTO(500,
                        "Error interno del servidor. Contacte con el administrador."));
    }
}