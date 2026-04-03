package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import com.citaria.dto.CredencialesDTO;
import com.citaria.model.Cliente;
import com.citaria.model.Credenciales;
import com.citaria.model.Organizacion;
import com.citaria.repository.ClienteDAO;
import com.citaria.repository.CredencialesDAO;
import com.citaria.repository.OrganizacionDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de clientes.
 * Incluye gestión de credenciales de acceso.
 */
@Service
public class ClienteServiceImpl implements ClienteService {

    private ClienteDAO clienteDAO;
    private CredencialesDAO credencialesDAO;
    private OrganizacionDAO organizacionDAO;

    @Autowired
    public ClienteServiceImpl(ClienteDAO clienteDAO,
                              CredencialesDAO credencialesDAO,
                              OrganizacionDAO organizacionDAO) {
        this.clienteDAO = clienteDAO;
        this.credencialesDAO = credencialesDAO;
        this.organizacionDAO = organizacionDAO;
    }

    // ===== CLIENTE =====

    @Override
    @Transactional(readOnly = true)
    public List<ClienteDTO> obtenerTodos(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<ClienteDTO> clientesDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Cliente> clientes = clienteDAO.findByOrganizacion(organizacion.get());
            for (Cliente cliente : clientes) {
                clientesDTO.add(convertirClienteADTO(cliente));
            }
        }
        return clientesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ClienteDTO> obtenerPorId(Integer id) {
        Optional<Cliente> cliente = clienteDAO.findById(id);
        if (cliente.isPresent()) {
            return Optional.of(convertirClienteADTO(cliente.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public ClienteDTO crear(Integer organizacionId, ClienteDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Cliente cliente = convertirClienteAEntidad(dto);
        cliente.setOrganizacion(organizacion.get());
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public Optional<ClienteDTO> actualizar(Integer id, ClienteDTO dto) {
        Optional<Cliente> existente = clienteDAO.findById(id);
        if (existente.isPresent()) {
            Cliente cliente = existente.get();
            actualizarCamposCliente(cliente, dto);
            return Optional.of(convertirClienteADTO(clienteDAO.save(cliente)));
        }
        return Optional.empty();
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

    // ===== CREDENCIALES =====

    @Override
    @Transactional(readOnly = true)
    public Optional<CredencialesDTO> obtenerCredencialesPorCliente(Integer clienteId) {
        Optional<Cliente> cliente = clienteDAO.findById(clienteId);
        if (cliente.isPresent()) {
            Optional<Credenciales> credenciales = credencialesDAO.findByCliente(cliente.get());
            if (credenciales.isPresent()) {
                return Optional.of(convertirCredencialesADTO(credenciales.get()));
            }
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public CredencialesDTO crearCredenciales(Integer clienteId, CredencialesDTO dto) {
        Optional<Cliente> cliente = clienteDAO.findById(clienteId);
        Credenciales credenciales = convertirCredencialesAEntidad(dto);
        credenciales.setCliente(cliente.get());
        return convertirCredencialesADTO(credencialesDAO.save(credenciales));
    }

    @Override
    @Transactional
    public Optional<CredencialesDTO> actualizarCredenciales(Integer clienteId, CredencialesDTO dto) {
        Optional<Cliente> cliente = clienteDAO.findById(clienteId);
        if (cliente.isPresent()) {
            Optional<Credenciales> existente = credencialesDAO.findByCliente(cliente.get());
            if (existente.isPresent()) {
                Credenciales credenciales = existente.get();
                actualizarCamposCredenciales(credenciales, dto);
                return Optional.of(convertirCredencialesADTO(credencialesDAO.save(credenciales)));
            }
        }
        return Optional.empty();
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

    private CredencialesDTO convertirCredencialesADTO(Credenciales credenciales) {
        CredencialesDTO dto = new CredencialesDTO();
        dto.setId(credenciales.getId());
        dto.setClienteId(credenciales.getCliente().getId());
        dto.setEmail(credenciales.getEmail());
        dto.setEmailVerificado(credenciales.getEmailVerificado());
        dto.setUltimoAcceso(credenciales.getUltimoAcceso());
        return dto;
    }

    private Credenciales convertirCredencialesAEntidad(CredencialesDTO dto) {
        Credenciales credenciales = new Credenciales();
        credenciales.setEmail(dto.getEmail());
        credenciales.setPasswordHash(dto.getPassword());
        credenciales.setEmailVerificado(false);
        return credenciales;
    }

    private void actualizarCamposCredenciales(Credenciales credenciales, CredencialesDTO dto) {
        credenciales.setEmail(dto.getEmail());
        if (dto.getPassword() != null) {
            credenciales.setPasswordHash(dto.getPassword());
        }
    }
}