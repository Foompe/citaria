package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.model.RolUsuario;

import java.util.List;

/**
 * Contrato del servicio de gestión de usuarios del sistema.
 */
public interface UsuarioService {

    List<UsuarioDTO> obtenerTodos(Integer organizacionId);
    List<UsuarioDTO> obtenerPorRol(Integer organizacionId, RolUsuario rol);
    UsuarioDTO obtenerPorId(Integer id);
    UsuarioDTO obtenerPorEmail(String email);
    UsuarioDTO crear(Integer organizacionId, UsuarioDTO dto);
    UsuarioDTO actualizar(Integer id, UsuarioDTO dto);
    boolean eliminar(Integer id);
}