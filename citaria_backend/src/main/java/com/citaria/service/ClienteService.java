package com.citaria.service;

import com.citaria.dto.ClienteDTO;

import java.util.List;

/**
 * Contrato del servicio de gestión de clientes.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 * La eliminación de un cliente se gestiona exclusivamente a través de
 * {@link UsuarioService#eliminar(Integer)}, que garantiza la anonimización
 * de datos personales en una única transacción.
 */
public interface ClienteService {

    List<ClienteDTO> obtenerTodos();
    ClienteDTO obtenerPorId(Integer id);
    ClienteDTO crear(ClienteDTO dto);
    ClienteDTO actualizar(Integer id, ClienteDTO dto);
}