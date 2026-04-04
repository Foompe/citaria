package com.citaria.service;

import com.citaria.dto.ClienteDTO;

import java.util.List;
import java.util.Optional;

/**
 * Contrato del servicio de gestión de clientes.
 * Incluye gestión de credenciales de acceso.
 */
public interface ClienteService {

    // Cliente
    List<ClienteDTO> obtenerTodos(Integer organizacionId);
    Optional<ClienteDTO> obtenerPorId(Integer id);
    ClienteDTO crear(Integer organizacionId, ClienteDTO dto);
    Optional<ClienteDTO> actualizar(Integer id, ClienteDTO dto);
    boolean eliminar(Integer id);
}