package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import com.citaria.repository.ClienteDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * Implementación del servicio de gestión de clientes.
 * La organización se resuelve automáticamente desde el contexto de seguridad,
 * garantizando que un usuario solo puede acceder a datos de su organización.
 */
@Service
public class ClienteServiceImpl implements ClienteService {

    private final ClienteDAO clienteDAO;
    private final ContextoSeguridad contextoSeguridad;

    public ClienteServiceImpl(ClienteDAO clienteDAO,
                              ContextoSeguridad contextoSeguridad) {
        this.clienteDAO = clienteDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClienteDTO> obtenerTodos() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Cliente> clientes = clienteDAO.findByOrganizacion(organizacion);
        List<ClienteDTO> clientesDTO = new ArrayList<>();
        for (Cliente cliente : clientes) {
            clientesDTO.add(convertirClienteADTO(cliente));
        }
        return clientesDTO;
    }

    /**
     * {@inheritDoc}
     *
     * Verifica que el cliente pertenezca a la organización del usuario autenticado.
     * Devuelve 404 en vez de 403 para no revelar que el recurso existe en otra organización.
     */
    @Override
    @Transactional(readOnly = true)
    public ClienteDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Cliente cliente = clienteDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + id + " no encontrado"));
        verificarTenencia(cliente, organizacion);
        return convertirClienteADTO(cliente);
    }

    @Override
    @Transactional
    public ClienteDTO crear(ClienteDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Cliente cliente = convertirClienteAEntidad(dto);
        cliente.setOrganizacion(organizacion);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public ClienteDTO actualizar(Integer id, ClienteDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Cliente cliente = clienteDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + id + " no encontrado"));
        verificarTenencia(cliente, organizacion);
        actualizarCamposCliente(cliente, dto);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    // MÉTODOS PRIVADOS

    /**
     * Verifica que el cliente pertenezca a la organización del usuario autenticado.
     * Lanza RecursoNoEncontradoException (404) en vez de un error de autorización (403)
     * para no revelar la existencia de recursos de otras organizaciones.
     */
    private void verificarTenencia(Cliente cliente, Organizacion organizacion) {
        if (!cliente.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Cliente con id " + cliente.getId() + " no encontrado");
        }
    }

    // CONVERSIONES

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