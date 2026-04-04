package com.citaria.service;

import com.citaria.dto.ClienteDTO;

import java.util.List;

/**
 * Contrato del servicio de gestión de clientes.
 */
public interface ClienteService {

    List<ClienteDTO> obtenerTodos(Integer organizacionId);
    ClienteDTO obtenerPorId(Integer id);
    ClienteDTO crear(Integer organizacionId, ClienteDTO dto);
    ClienteDTO actualizar(Integer id, ClienteDTO dto);
    boolean eliminar(Integer id);
}