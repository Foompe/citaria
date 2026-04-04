package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import com.citaria.repository.ClienteDAO;
import com.citaria.repository.OrganizacionDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * Implementación del servicio de gestión de clientes.
 */
@Service
public class ClienteServiceImpl implements ClienteService {

    private ClienteDAO clienteDAO;
    private OrganizacionDAO organizacionDAO;

    @Autowired
    public ClienteServiceImpl(ClienteDAO clienteDAO,
                              OrganizacionDAO organizacionDAO) {
        this.clienteDAO = clienteDAO;
        this.organizacionDAO = organizacionDAO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClienteDTO> obtenerTodos(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<Cliente> clientes = clienteDAO.findByOrganizacion(organizacion);
        List<ClienteDTO> clientesDTO = new ArrayList<>();
        for (Cliente cliente : clientes) {
            clientesDTO.add(convertirClienteADTO(cliente));
        }
        return clientesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public ClienteDTO obtenerPorId(Integer id) {
        Cliente cliente = clienteDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + id + " no encontrado"));
        return convertirClienteADTO(cliente);
    }

    @Override
    @Transactional
    public ClienteDTO crear(Integer organizacionId, ClienteDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        Cliente cliente = convertirClienteAEntidad(dto);
        cliente.setOrganizacion(organizacion);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public ClienteDTO actualizar(Integer id, ClienteDTO dto) {
        Cliente cliente = clienteDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + id + " no encontrado"));
        actualizarCamposCliente(cliente, dto);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public boolean eliminar(Integer id) {
        if (clienteDAO.existsById(id)) {
            clienteDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== CONVERSIONES =====

    private ClienteDTO convertirClienteADTO(Cliente cliente) {
        ClienteDTO dto = new ClienteDTO();
        dto.setId(cliente.getId());
        dto.setOrganizacionId(cliente.getOrganizacion().getId());
        dto.setNombre(cliente.getNombre());
        dto.setApellidos(cliente.getApellidos());
        dto.setDni(cliente.getDni());
        dto.setEmail(cliente.getEmail());
        dto.setTelefono(cliente.getTelefono());
        dto.setNotas(cliente.getNotas());
        dto.setAnonimizadoAt(cliente.getAnonimizadoAt());
        return dto;
    }

    private Cliente convertirClienteAEntidad(ClienteDTO dto) {
        Cliente cliente = new Cliente();
        cliente.setNombre(dto.getNombre());
        cliente.setApellidos(dto.getApellidos());
        cliente.setDni(dto.getDni());
        cliente.setEmail(dto.getEmail());
        cliente.setTelefono(dto.getTelefono());
        cliente.setNotas(dto.getNotas());
        return cliente;
    }

    private void actualizarCamposCliente(Cliente cliente, ClienteDTO dto) {
        cliente.setNombre(dto.getNombre());
        cliente.setApellidos(dto.getApellidos());
        cliente.setDni(dto.getDni());
        cliente.setEmail(dto.getEmail());
        cliente.setTelefono(dto.getTelefono());
        cliente.setNotas(dto.getNotas());
    }
}