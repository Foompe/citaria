package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.model.RolUsuario;
import java.util.List;

/**
 * Servicio de gestión de usuarios.
 */
public interface UsuarioService {

    List<UsuarioDTO> obtenerTodos();
    List<UsuarioDTO> obtenerPorRol(RolUsuario rol);
    UsuarioDTO obtenerPorId(Integer id);
    UsuarioDTO crear(UsuarioDTO dto);
    UsuarioDTO actualizar(Integer id, UsuarioDTO dto);

    /**
     * Elimina físicamente la cuenta de usuario y anonimiza sus entidades vinculadas (Cliente/Empleado).
     */
    void eliminar(Integer id);

}