package com.citaria.exception;

import com.citaria.dto.ErrorConCampoRespuestaDTO;
import com.citaria.dto.ErrorRespuestaDTO;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Centraliza el manejo de errores controlando los mensajes devueltos.
 */
@RestControllerAdvice
public class ManejadorGlobalExcepciones {

    /**
     * Maneja credenciales incorrectas en el login.
     */
    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarAutenticacion(AuthenticationException ex) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorRespuestaDTO(401, "Credenciales incorrectas o cuenta desactivada"));
    }

    /**
     * Maneja detección de cliente duplicado por email o DNI.
     */
    @ExceptionHandler(ClienteDuplicadoException.class)
    public ResponseEntity<ErrorConCampoRespuestaDTO> manejarClienteDuplicado(ClienteDuplicadoException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(new ErrorConCampoRespuestaDTO(409, ex.getMessage(), ex.getCampo()));
    }

    /**
     * Maneja intentos de baja de empleado con reservas activas.
     */
    @ExceptionHandler(EmpleadoConReservasActivasException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarEmpleadoConReservas(EmpleadoConReservasActivasException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(new ErrorRespuestaDTO(409, ex.getMessage()));
    }

    /**
     * Maneja operaciones no permitidas según el estado o el rol.
     */
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarEstadoIlegal(IllegalStateException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(new ErrorRespuestaDTO(409, ex.getMessage()));
    }

    /**
     * Maneja recursos no encontrados.
     */
    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarRecursoNoEncontrado(RecursoNoEncontradoException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(new ErrorRespuestaDTO(404, ex.getMessage()));
    }

    /**
     * Maneja intentos de registro con un email ya existente.
     */
    @ExceptionHandler(EmailYaRegistradoException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarEmailYaRegistrado(EmailYaRegistradoException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(new ErrorRespuestaDTO(409, ex.getMessage()));
    }

    /**
     * Maneja errores producidos al subir imágenes a Cloudinary.
     */
    @ExceptionHandler(ImagenSubidaException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarImagenSubida(ImagenSubidaException ex) {
        return ResponseEntity
                .status(HttpStatus.BAD_GATEWAY)
                .body(new ErrorRespuestaDTO(502, ex.getMessage()));
    }

    /**
     * Maneja errores de validación de campos.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarValidacion(MethodArgumentNotValidException ex) {
        String mensaje = "Error de validación";
        if (!ex.getBindingResult().getFieldErrors().isEmpty()) {
            org.springframework.validation.FieldError error =
                    ex.getBindingResult().getFieldErrors().get(0);
            mensaje = error.getField() + ": " + error.getDefaultMessage();
        }
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(new ErrorRespuestaDTO(400, mensaje));
    }

    /**
     * Maneja cualquier excepción no controlada.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorRespuestaDTO> manejarExcepcionGeneral(Exception ex) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorRespuestaDTO(500,
                        "Error interno del servidor. Contacte con el administrador."));
    }
}
