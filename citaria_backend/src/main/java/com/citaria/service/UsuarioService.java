package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.model.RolUsuario;

import java.util.List;
import java.util.Optional;

/**
 * Contrato del servicio de gestión de usuarios del sistema.
 */
public interface UsuarioService {

    List<UsuarioDTO> obtenerTodos(Integer organizacionId);
    List<UsuarioDTO> obtenerPorRol(Integer organizacionId, RolUsuario rol);
    Optional<UsuarioDTO> obtenerPorId(Integer id);
    Optional<UsuarioDTO> obtenerPorEmail(String email);
    UsuarioDTO crear(Integer organizacionId, UsuarioDTO dto);
    Optional<UsuarioDTO> actualizar(Integer id, UsuarioDTO dto);
    boolean eliminar(Integer id);
}