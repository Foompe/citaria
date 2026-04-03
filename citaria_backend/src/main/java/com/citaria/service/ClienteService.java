package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import com.citaria.dto.CredencialesDTO;

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

    // Credenciales
    Optional<CredencialesDTO> obtenerCredencialesPorCliente(Integer clienteId);
    CredencialesDTO crearCredenciales(Integer clienteId, CredencialesDTO dto);
    Optional<CredencialesDTO> actualizarCredenciales(Integer clienteId, CredencialesDTO dto);
}