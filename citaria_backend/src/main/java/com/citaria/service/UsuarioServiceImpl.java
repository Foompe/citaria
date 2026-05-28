package com.citaria.service;

import com.citaria.dto.PeticionCambioPasswordDTO;
import com.citaria.dto.UsuarioDTO;
import com.citaria.exception.EmpleadoConReservasActivasException;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de usuarios del sistema.
 */
@Service
public class UsuarioServiceImpl implements UsuarioService {

    private final UsuarioDAO usuarioDAO;
    private final ClienteDAO clienteDAO;
    private final EmpleadoDAO empleadoDAO;
    private final ReservaDAO reservaDAO;
    private final PasswordEncoder passwordEncoder;
    private final ContextoSeguridad contextoSeguridad;

    @Autowired
    public UsuarioServiceImpl(UsuarioDAO usuarioDAO,
                              ClienteDAO clienteDAO,
                              EmpleadoDAO empleadoDAO,
                              ReservaDAO reservaDAO,
                              PasswordEncoder passwordEncoder,
                              ContextoSeguridad contextoSeguridad) {
        this.usuarioDAO = usuarioDAO;
        this.clienteDAO = clienteDAO;
        this.empleadoDAO = empleadoDAO;
        this.reservaDAO = reservaDAO;
        this.passwordEncoder = passwordEncoder;
        this.contextoSeguridad = contextoSeguridad;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UsuarioDTO> obtenerTodos() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Usuario> usuarios = usuarioDAO.findByOrganizacion(organizacion);
        List<UsuarioDTO> usuariosDTO = new ArrayList<>();
        for (Usuario usuario : usuarios) {
            usuariosDTO.add(convertirADTO(usuario));
        }
        return usuariosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UsuarioDTO> obtenerPorRol(RolUsuario rol) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Usuario> usuarios = usuarioDAO.findByOrganizacionAndRol(organizacion, rol);
        List<UsuarioDTO> usuariosDTO = new ArrayList<>();
        for (Usuario usuario : usuarios) {
            usuariosDTO.add(convertirADTO(usuario));
        }
        return usuariosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public UsuarioDTO obtenerActual() {
        Usuario usuario = contextoSeguridad.obtenerUsuarioActual();
        return convertirADTO(usuario);
    }

    @Override
    @Transactional(readOnly = true)
    public UsuarioDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Usuario> usuarioOptional = usuarioDAO.findById(id);
        if (usuarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Usuario con id " + id + " no encontrado");
        }
        Usuario usuario = usuarioOptional.get();
        verificarPertenencia(usuario, organizacion);
        return convertirADTO(usuario);
    }

    @Override
    @Transactional
    public UsuarioDTO crear(UsuarioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Usuario usuario = convertirAEntidad(dto);
        usuario.setOrganizacion(organizacion);
        if (dto.getClienteId() != null) {
            Optional<Cliente> cliente = clienteDAO.findById(dto.getClienteId());
            if (cliente.isPresent()) {
                Cliente clienteEncontrado = cliente.get();
                if (!clienteEncontrado.getOrganizacion().getId().equals(organizacion.getId())) {
                    throw new RecursoNoEncontradoException(
                            "Cliente con id " + dto.getClienteId() + " no encontrado");
                }
                usuario.setCliente(clienteEncontrado);
            }
        }
        if (dto.getEmpleadoId() != null) {
            Optional<Empleado> empleado = empleadoDAO.findById(dto.getEmpleadoId());
            if (empleado.isPresent()) {
                Empleado empleadoEncontrado = empleado.get();
                if (!empleadoEncontrado.getOrganizacion().getId().equals(organizacion.getId())) {
                    throw new RecursoNoEncontradoException(
                            "Empleado con id " + dto.getEmpleadoId() + " no encontrado");
                }
                usuario.setEmpleado(empleadoEncontrado);
            }
        }
        return convertirADTO(usuarioDAO.save(usuario));
    }

    @Override
    @Transactional
    public UsuarioDTO actualizar(Integer id, UsuarioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Usuario> usuarioOptional = usuarioDAO.findById(id);
        if (usuarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Usuario con id " + id + " no encontrado");
        }
        Usuario usuario = usuarioOptional.get();
        verificarPertenencia(usuario, organizacion);
        actualizarCamposUsuario(usuario, dto);
        if (dto.getClienteId() != null) {
            Optional<Cliente> cliente = clienteDAO.findById(dto.getClienteId());
            if (cliente.isPresent()) {
                Cliente clienteEncontrado = cliente.get();
                if (!clienteEncontrado.getOrganizacion().getId().equals(organizacion.getId())) {
                    throw new RecursoNoEncontradoException(
                            "Cliente con id " + dto.getClienteId() + " no encontrado");
                }
                usuario.setCliente(clienteEncontrado);
            }
        }
        if (dto.getEmpleadoId() != null) {
            Optional<Empleado> empleado = empleadoDAO.findById(dto.getEmpleadoId());
            if (empleado.isPresent()) {
                Empleado empleadoEncontrado = empleado.get();
                if (!empleadoEncontrado.getOrganizacion().getId().equals(organizacion.getId())) {
                    throw new RecursoNoEncontradoException(
                            "Empleado con id " + dto.getEmpleadoId() + " no encontrado");
                }
                usuario.setEmpleado(empleadoEncontrado);
            }
        }
        return convertirADTO(usuarioDAO.save(usuario));
    }

    /**
     * {@inheritDoc}
     *
     * Si el usuario es un empleado con reservas futuras activas lanza una exception.
     * El front debe consultar GET /api/empleados/{id}/reservas-activas antes de proceder con la baja.
     * <p>
     * La cuenta de usuario se elimina físicamente, conservando las entidades
     * históricas vinculadas con sus datos personales anonimizados.
     */
    @Override
    @Transactional
    public void eliminar(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Usuario> usuarioOptional = usuarioDAO.findById(id);
        if (usuarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Usuario con id " + id + " no encontrado");
        }
        Usuario usuario = usuarioOptional.get();
        verificarPertenencia(usuario, organizacion);

        if (usuario.getEmpleado() != null) {
            List<EstadoReserva> estadosActivos = new ArrayList<>();
            estadosActivos.add(EstadoReserva.pendiente);
            estadosActivos.add(EstadoReserva.confirmada);

            List<Reserva> reservasActivas = reservaDAO.findReservasFuturasActivasPorEmpleado(
                    usuario.getEmpleado(), LocalDate.now(), estadosActivos);
            if (!reservasActivas.isEmpty()) {
                throw new EmpleadoConReservasActivasException();
            }
        }

        usuarioDAO.delete(usuario);
        if (usuario.getCliente() != null) {
            anonimizarCliente(usuario.getCliente());
        }
        if (usuario.getEmpleado() != null) {
            anonimizarEmpleado(usuario.getEmpleado());
        }
    }

    @Override
    @Transactional
    public void cambiarPassword(PeticionCambioPasswordDTO peticion) {
        Usuario usuario = contextoSeguridad.obtenerUsuarioActual();
        if (!passwordEncoder.matches(peticion.getPasswordActual(), usuario.getPasswordHash())) {
            throw new IllegalArgumentException("La contraseña actual no es correcta");
        }
        usuario.setPasswordHash(passwordEncoder.encode(peticion.getPasswordNueva()));
        usuarioDAO.save(usuario);
    }

    // ANONIMIZACIÓN

    private void anonimizarCliente(Cliente cliente) {
        cliente.setNombre(AnonimizacionConstantes.NOMBRE_ANONIMIZADO);
        cliente.setApellidos(null);
        cliente.setDni(null);
        cliente.setEmail(null);
        cliente.setTelefono(null);
        cliente.setNotas(null);
        cliente.setAnonimizadoAt(LocalDateTime.now());
        clienteDAO.save(cliente);
    }

    private void anonimizarEmpleado(Empleado empleado) {
        empleado.setNombre(AnonimizacionConstantes.NOMBRE_ANONIMIZADO);
        empleado.setApellidos(null);
        empleado.setEmail(null);
        empleado.setTelefono(null);
        empleado.setActivo(false);
        empleado.setAnonimizadoAt(LocalDateTime.now());
        empleadoDAO.save(empleado);
    }

    //MÉTODOS AUXILIARES

    // VERIFICACIÓN DE PERTENENCIA

    private void verificarPertenencia(Usuario usuario, Organizacion organizacion) {
        if (!usuario.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Usuario con id " + usuario.getId() + " no encontrado");
        }
    }

    // CONVERSIONES

    private UsuarioDTO convertirADTO(Usuario usuario) {
        UsuarioDTO dto = new UsuarioDTO();
        dto.setId(usuario.getId());
        dto.setOrganizacionId(usuario.getOrganizacion().getId());
        dto.setEmail(usuario.getEmail());
        dto.setRol(usuario.getRol());
        dto.setActivo(usuario.getActivo());
        dto.setEmailVerificado(usuario.getEmailVerificado());
        dto.setUltimoAcceso(usuario.getUltimoAcceso());
        if (usuario.getCliente() != null) {
            dto.setClienteId(usuario.getCliente().getId());
        }
        if (usuario.getEmpleado() != null) {
            dto.setEmpleadoId(usuario.getEmpleado().getId());
        }
        return dto;
    }

    private Usuario convertirAEntidad(UsuarioDTO dto) {
        Usuario usuario = new Usuario();
        usuario.setEmail(dto.getEmail());
        usuario.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        usuario.setRol(dto.getRol());
        if (dto.getActivo() != null) {
            usuario.setActivo(dto.getActivo());
        } else {
            usuario.setActivo(true);
        }
        usuario.setEmailVerificado(false);
        return usuario;
    }

    private void actualizarCamposUsuario(Usuario usuario, UsuarioDTO dto) {
        usuario.setEmail(dto.getEmail());
        usuario.setRol(dto.getRol());
        usuario.setActivo(dto.getActivo());
        if (dto.getPassword() != null) {
            usuario.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        }
    }
}
