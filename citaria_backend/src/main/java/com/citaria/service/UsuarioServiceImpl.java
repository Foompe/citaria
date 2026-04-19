package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Implementación del servicio de gestión de usuarios del sistema.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 */
@Service
public class UsuarioServiceImpl implements UsuarioService {

    private static final String NOMBRE_ANONIMIZADO = "Anónimo";
    private static final String DOMINIO_ANONIMIZADO = "@eliminado.local";

    private final UsuarioDAO usuarioDAO;
    private final ClienteDAO clienteDAO;
    private final EmpleadoDAO empleadoDAO;
    private final PasswordEncoder passwordEncoder;
    private final ContextoSeguridad contextoSeguridad;

    public UsuarioServiceImpl(UsuarioDAO usuarioDAO,
                              ClienteDAO clienteDAO,
                              EmpleadoDAO empleadoDAO,
                              PasswordEncoder passwordEncoder,
                              ContextoSeguridad contextoSeguridad) {
        this.usuarioDAO = usuarioDAO;
        this.clienteDAO = clienteDAO;
        this.empleadoDAO = empleadoDAO;
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
    public UsuarioDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Usuario usuario = usuarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con id " + id + " no encontrado"));
        verificarTenencia(usuario, organizacion);
        return convertirADTO(usuario);
    }

    @Override
    @Transactional(readOnly = true)
    public UsuarioDTO obtenerPorEmail(String email) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Usuario usuario = usuarioDAO.findByEmailAndOrganizacion(email, organizacion)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario no encontrado"));
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
            cliente.ifPresent(usuario::setCliente);
        }
        if (dto.getEmpleadoId() != null) {
            Optional<Empleado> empleado = empleadoDAO.findById(dto.getEmpleadoId());
            empleado.ifPresent(usuario::setEmpleado);
        }
        return convertirADTO(usuarioDAO.save(usuario));
    }

    @Override
    @Transactional
    public UsuarioDTO actualizar(Integer id, UsuarioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Usuario usuario = usuarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con id " + id + " no encontrado"));
        verificarTenencia(usuario, organizacion);
        actualizarCamposUsuario(usuario, dto);
        if (dto.getClienteId() != null) {
            Optional<Cliente> cliente = clienteDAO.findById(dto.getClienteId());
            cliente.ifPresent(usuario::setCliente);
        }
        if (dto.getEmpleadoId() != null) {
            Optional<Empleado> empleado = empleadoDAO.findById(dto.getEmpleadoId());
            empleado.ifPresent(usuario::setEmpleado);
        }
        return convertirADTO(usuarioDAO.save(usuario));
    }

    /**
     * {@inheritDoc}
     *
     * El email se sustituye por un placeholder único con UUID para respetar
     * la constraint UNIQUE(email, organizacion_id) sin dejar datos personales.
     * El passwordHash se reemplaza por un hash de UUID aleatorio — inutilizable para login.
     */
    @Override
    @Transactional
    public void eliminar(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Usuario usuario = usuarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con id " + id + " no encontrado"));
        verificarTenencia(usuario, organizacion);
        anonimizarUsuario(usuario);
        if (usuario.getCliente() != null) {
            anonimizarCliente(usuario.getCliente());
        }
        if (usuario.getEmpleado() != null) {
            anonimizarEmpleado(usuario.getEmpleado());
        }
    }

    // ===== ANONIMIZACIÓN =====

    private void anonimizarUsuario(Usuario usuario) {
        usuario.setEmail("anonimizado-" + UUID.randomUUID() + DOMINIO_ANONIMIZADO);
        usuario.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
        usuario.setActivo(false);
    }

    private void anonimizarCliente(Cliente cliente) {
        cliente.setNombre(NOMBRE_ANONIMIZADO);
        cliente.setApellidos(null);
        cliente.setDni(null);
        cliente.setEmail(null);
        cliente.setTelefono(null);
        cliente.setNotas(null);
        cliente.setAnonimizadoAt(LocalDateTime.now());
    }

    private void anonimizarEmpleado(Empleado empleado) {
        empleado.setActivo(false);
        empleado.setAnonimizadoAt(LocalDateTime.now());
    }

    // ===== VERIFICACIÓN DE TENENCIA =====

    private void verificarTenencia(Usuario usuario, Organizacion organizacion) {
        if (!usuario.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Usuario con id " + usuario.getId() + " no encontrado");
        }
    }

    // ===== CONVERSIONES =====

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
        usuario.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
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