package com.citaria.service;

import com.citaria.dto.UsuarioDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de usuarios del sistema.
 */
@Service
public class UsuarioServiceImpl implements UsuarioService {

    private UsuarioDAO usuarioDAO;
    private OrganizacionDAO organizacionDAO;
    private ClienteDAO clienteDAO;
    private EmpleadoDAO empleadoDAO;
    private PasswordEncoder passwordEncoder;

    @Autowired
    public UsuarioServiceImpl(UsuarioDAO usuarioDAO,
                              OrganizacionDAO organizacionDAO,
                              ClienteDAO clienteDAO,
                              EmpleadoDAO empleadoDAO,
                              PasswordEncoder passwordEncoder) {
        this.usuarioDAO = usuarioDAO;
        this.organizacionDAO = organizacionDAO;
        this.clienteDAO = clienteDAO;
        this.empleadoDAO = empleadoDAO;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UsuarioDTO> obtenerTodos(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<Usuario> usuarios = usuarioDAO.findByOrganizacion(organizacion);
        List<UsuarioDTO> usuariosDTO = new ArrayList<>();
        for (Usuario usuario : usuarios) {
            usuariosDTO.add(convertirADTO(usuario));
        }
        return usuariosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UsuarioDTO> obtenerPorRol(Integer organizacionId, RolUsuario rol) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
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
        Usuario usuario = usuarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con id " + id + " no encontrado"));
        return convertirADTO(usuario);
    }

    @Override
    @Transactional(readOnly = true)
    public UsuarioDTO obtenerPorEmail(String email) {
        Usuario usuario = usuarioDAO.findByEmail(email)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con email " + email + " no encontrado"));
        return convertirADTO(usuario);
    }

    @Override
    @Transactional
    public UsuarioDTO crear(Integer organizacionId, UsuarioDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
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
        Usuario usuario = usuarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario con id " + id + " no encontrado"));
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

    @Override
    @Transactional
    public boolean eliminar(Integer id) {
        if (usuarioDAO.existsById(id)) {
            usuarioDAO.deleteById(id);
            return true;
        }
        return false;
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