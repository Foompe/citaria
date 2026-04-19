package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.model.RolUsuario;

import java.util.List;

/**
 * Contrato del servicio de gestión de usuarios del sistema.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 */
public interface UsuarioService {

    List<UsuarioDTO> obtenerTodos();
    List<UsuarioDTO> obtenerPorRol(RolUsuario rol);
    UsuarioDTO obtenerPorId(Integer id);
    UsuarioDTO obtenerPorEmail(String email);
    UsuarioDTO crear(UsuarioDTO dto);
    UsuarioDTO actualizar(Integer id, UsuarioDTO dto);

    /**
     * Anonimiza de forma irreversible los datos personales del usuario y sus
     * entidades vinculadas (Cliente/Empleado), desactivando el acceso al sistema.
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     *
     * @param id identificador del usuario a anonimizar
     */
    void eliminar(Integer id);
}