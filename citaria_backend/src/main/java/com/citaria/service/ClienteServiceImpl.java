package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import com.citaria.exception.ClienteDuplicadoException;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Cliente;
import com.citaria.model.EstadoReserva;
import com.citaria.model.EstadoReservaServicio;
import com.citaria.model.Organizacion;
import com.citaria.model.Reserva;
import com.citaria.model.RolUsuario;
import com.citaria.model.Usuario;
import com.citaria.repository.ClienteDAO;
import com.citaria.repository.ReservaDAO;
import com.citaria.repository.ReservaServicioDAO;
import com.citaria.repository.UsuarioDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Implementación del servicio de gestión de clientes.
 */
@Service
public class ClienteServiceImpl implements ClienteService {

    private final ClienteDAO clienteDAO;
    private final UsuarioDAO usuarioDAO;
    private final ReservaDAO reservaDAO;
    private final ReservaServicioDAO reservaServicioDAO;
    private final ContextoSeguridad contextoSeguridad;
    private final ImagenService imagenService;

    @Autowired
    public ClienteServiceImpl(ClienteDAO clienteDAO,
                              UsuarioDAO usuarioDAO,
                              ReservaDAO reservaDAO,
                              ReservaServicioDAO reservaServicioDAO,
                              ContextoSeguridad contextoSeguridad,
                              ImagenService imagenService) {
        this.clienteDAO = clienteDAO;
        this.usuarioDAO = usuarioDAO;
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.contextoSeguridad = contextoSeguridad;
        this.imagenService = imagenService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClienteDTO> obtenerTodos() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Cliente> clientes = clienteDAO.findByOrganizacion(organizacion);

        List<ClienteDTO> clientesDTO = new ArrayList<>();
        Set<Integer> clientesConUsuarioIds = obtenerClientesConUsuarioIds(clientes);
        for (Cliente cliente : clientes) {
            clientesDTO.add(convertirClienteADTO(cliente, clientesConUsuarioIds.contains(cliente.getId())));
        }
        return clientesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClienteDTO> buscarClientes(String dni, String email, String telefono) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Cliente> clientes = new ArrayList<>();

        if (dni != null && !dni.isBlank()) {
            Optional<Cliente> clienteOptional = clienteDAO.findByDniAndOrganizacion(dni, organizacion);
            if (clienteOptional.isPresent()) {
                clientes.add(clienteOptional.get());
            }
        } else if (email != null && !email.isBlank()) {
            Optional<Cliente> clienteOptional = clienteDAO.findByEmailAndOrganizacion(email, organizacion);
            if (clienteOptional.isPresent()) {
                clientes.add(clienteOptional.get());
            }
        } else if (telefono != null && !telefono.isBlank()) {
            clientes = clienteDAO.findByTelefonoAndOrganizacion(telefono, organizacion);
        }

        List<ClienteDTO> clientesDTO = new ArrayList<>();
        Set<Integer> clientesConUsuarioIds = obtenerClientesConUsuarioIds(clientes);
        for (Cliente cliente : clientes) {
            clientesDTO.add(convertirClienteADTO(cliente, clientesConUsuarioIds.contains(cliente.getId())));
        }
        return clientesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public ClienteDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Cliente> clienteOptional = clienteDAO.findById(id);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + id + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarTenencia(cliente, organizacion);
        verificarAccesoPropio(id);
        return convertirClienteADTO(cliente);
    }

    @Override
    @Transactional
    public ClienteDTO crear(ClienteDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        verificarDuplicados(dto, null, organizacion);
        Cliente cliente = convertirClienteAEntidad(dto);
        cliente.setOrganizacion(organizacion);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public ClienteDTO actualizar(Integer id, ClienteDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Cliente> clienteOptional = clienteDAO.findById(id);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + id + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarTenencia(cliente, organizacion);
        verificarAccesoPropio(id);
        verificarDuplicados(dto, id, organizacion);
        actualizarCamposCliente(cliente, dto);
        return convertirClienteADTO(clienteDAO.save(cliente));
    }

    @Override
    @Transactional
    public void subirFotoCliente(Integer id, MultipartFile archivo) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Cliente> clienteOptional = clienteDAO.findById(id);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + id + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarTenencia(cliente, organizacion);
        verificarAccesoPropio(id);
        String fotoUrl = imagenService.subirImagen(archivo);
        cliente.setFotoUrl(fotoUrl);
        clienteDAO.save(cliente);
    }

    /**
     * Cancela las reservas futuras activas del cliente antes de anonimizar.
     */
    @Override
    @Transactional
    public void anonimizarCliente(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Cliente> clienteOptional = clienteDAO.findById(id);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + id + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarTenencia(cliente, organizacion);

        List<EstadoReserva> estadosActivos = new ArrayList<>();
        estadosActivos.add(EstadoReserva.pendiente);
        estadosActivos.add(EstadoReserva.confirmada);

        List<Reserva> reservasActivas = reservaDAO.findReservasFuturasActivasPorCliente(
                cliente, LocalDate.now(), estadosActivos);
        for (Reserva reserva : reservasActivas) {
            reserva.setEstado(EstadoReserva.cancelada);
            reserva.setMotivo("Cliente dado de baja");
            reservaServicioDAO.cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
        }

        Optional<Usuario> usuarioOptional = usuarioDAO.findByCliente(cliente);
        if (usuarioOptional.isPresent()) {
            usuarioDAO.delete(usuarioOptional.get());
        }
        anonimizarCliente(cliente);
    }

    // MÉTODOS AUXILIARES

    private void verificarTenencia(Cliente cliente, Organizacion organizacion) {
        if (!cliente.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Cliente con id " + cliente.getId() + " no encontrado");
        }
    }

    /**
     * Si el usuario autenticado es ROLE_CLIENTE, verifica que solo acceda a su propio perfil.
     * Los roles ADMIN y EMPLEADO pueden acceder a cualquier cliente de su organización.
     */
    private void verificarAccesoPropio(Integer clienteId) {
        Usuario usuario = contextoSeguridad.obtenerUsuarioActual();
        if (usuario.getRol() == RolUsuario.CLIENTE) {
            Integer propioClienteId = contextoSeguridad.obtenerClienteIdActual();
            if (!propioClienteId.equals(clienteId)) {
                throw new RecursoNoEncontradoException("Cliente con id " + clienteId + " no encontrado");
            }
        }
    }

    /**
     * Verifica que no exista otro cliente con el mismo email o DNI dentro de la organización.
     */
    private void verificarDuplicados(ClienteDTO dto, Integer idActual, Organizacion organizacion) {
        if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
            Optional<Cliente> existente = clienteDAO.findByEmailAndOrganizacion(dto.getEmail(), organizacion);
            if (existente.isPresent() && !existente.get().getId().equals(idActual)) {
                throw new ClienteDuplicadoException("email");
            }
        }
        if (dto.getDni() != null && !dto.getDni().isBlank()) {
            Optional<Cliente> existente = clienteDAO.findByDniAndOrganizacion(dto.getDni(), organizacion);
            if (existente.isPresent() && !existente.get().getId().equals(idActual)) {
                throw new ClienteDuplicadoException("dni");
            }
        }
    }

    private void anonimizarCliente(Cliente cliente) {
        cliente.setNombre(AnonimizacionConstantes.NOMBRE_ANONIMIZADO);
        cliente.setApellidos(null);
        cliente.setDni(null);
        cliente.setEmail(null);
        cliente.setTelefono(null);
        cliente.setNotas(null);
        cliente.setFotoUrl(null);
        cliente.setAnonimizadoAt(LocalDateTime.now());
        clienteDAO.save(cliente);
    }

    /**
     * Devuelve los ids de clientes que ya tienen un usuario vinculado.
     */
    private Set<Integer> obtenerClientesConUsuarioIds(List<Cliente> clientes) {
        Set<Integer> clientesConUsuarioIds = new HashSet<>();
        if (clientes.isEmpty()) {
            return clientesConUsuarioIds;
        }
        List<Usuario> usuarios = usuarioDAO.findByClienteIn(clientes);
        for (Usuario usuario : usuarios) {
            if (usuario.getCliente() != null) {
                clientesConUsuarioIds.add(usuario.getCliente().getId());
            }
        }
        return clientesConUsuarioIds;
    }

    // CONVERSIONES

    private ClienteDTO convertirClienteADTO(Cliente cliente) {
        return convertirClienteADTO(cliente, usuarioDAO.findByCliente(cliente).isPresent());
    }

    private ClienteDTO convertirClienteADTO(Cliente cliente, boolean tieneUsuario) {
        ClienteDTO dto = new ClienteDTO();
        dto.setId(cliente.getId());
        dto.setOrganizacionId(cliente.getOrganizacion().getId());
        dto.setNombre(cliente.getNombre());
        dto.setApellidos(cliente.getApellidos());
        dto.setDni(cliente.getDni());
        dto.setEmail(cliente.getEmail());
        dto.setTelefono(cliente.getTelefono());
        dto.setNotas(cliente.getNotas());
        dto.setFotoUrl(cliente.getFotoUrl());
        dto.setAnonimizadoAt(cliente.getAnonimizadoAt());
        dto.setTieneUsuario(tieneUsuario);
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
        cliente.setFotoUrl(dto.getFotoUrl());
        return cliente;
    }

    private void actualizarCamposCliente(Cliente cliente, ClienteDTO dto) {
        cliente.setNombre(dto.getNombre());
        cliente.setApellidos(dto.getApellidos());
        cliente.setDni(dto.getDni());
        cliente.setEmail(dto.getEmail());
        cliente.setTelefono(dto.getTelefono());
        cliente.setNotas(dto.getNotas());
        cliente.setFotoUrl(dto.getFotoUrl());
    }
}
