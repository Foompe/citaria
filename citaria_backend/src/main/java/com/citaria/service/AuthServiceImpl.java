package com.citaria.service;

import org.springframework.beans.factory.annotation.Autowired;
import com.citaria.dto.PeticionLoginDTO;
import com.citaria.dto.LoginRespuestaDTO;
import com.citaria.dto.RegistroRequestDTO;
import com.citaria.exception.EmailYaRegistradoException;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import com.citaria.model.RolUsuario;
import com.citaria.model.Usuario;
import com.citaria.repository.ClienteDAO;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.UsuarioDAO;
import com.citaria.security.JwtUtil;
import com.citaria.security.UsuarioDetailsService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Implementación del servicio de autenticación.
 */
@Service
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final UsuarioDAO usuarioDAO;
    private final OrganizacionDAO organizacionDAO;
    private final ClienteDAO clienteDAO;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthServiceImpl(AuthenticationManager authenticationManager,
                           UsuarioDAO usuarioDAO,
                           OrganizacionDAO organizacionDAO,
                           ClienteDAO clienteDAO,
                           JwtUtil jwtUtil,
                           PasswordEncoder passwordEncoder) {
        this.authenticationManager = authenticationManager;
        this.usuarioDAO = usuarioDAO;
        this.organizacionDAO = organizacionDAO;
        this.clienteDAO = clienteDAO;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    // LOGIN

    /**
     * {@inheritDoc}
     */
    @Override
    @Transactional
    public LoginRespuestaDTO login(PeticionLoginDTO loginRequest) {
        Optional<Organizacion> organizacionOptional = organizacionDAO.findById(loginRequest.getOrganizacionId());
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Organización no encontrada");
        }
        Organizacion organizacion = organizacionOptional.get();

        String usernameCompuesto = UsuarioDetailsService.construirUsername(
                loginRequest.getEmail(), organizacion.getId());

        Authentication autenticacion = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        usernameCompuesto,
                        loginRequest.getPassword()
                )
        );

        Optional<Usuario> usuarioOptional = usuarioDAO.findByEmailAndOrganizacion(
                loginRequest.getEmail(), organizacion);
        if (usuarioOptional.isEmpty()) {
            throw new IllegalStateException("Inconsistencia interna: usuario autenticado no encontrado en BD");
        }
        Usuario usuario = usuarioOptional.get();

        usuario.setUltimoAcceso(LocalDateTime.now());
        usuarioDAO.save(usuario);

        String token = jwtUtil.generateToken(
                usuario.getEmail(),
                usuario.getRol().name(),
                organizacion.getId()
        );
        return new LoginRespuestaDTO(token);
    }

    // REGISTRO

    /**
     * {@inheritDoc}
     */
    @Override
    @Transactional
    public LoginRespuestaDTO registro(RegistroRequestDTO registroRequest) {
        Optional<Organizacion> organizacionOptional = organizacionDAO.findByTokenRegistro(
                registroRequest.getTokenRegistro());
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Token de registro inválido");
        }
        Organizacion organizacion = organizacionOptional.get();

        if (usuarioDAO.existsByEmailAndOrganizacion(registroRequest.getEmail(), organizacion)) {
            throw new EmailYaRegistradoException("El email ya está registrado en el sistema");
        }

        Cliente cliente = resolverCliente(registroRequest, organizacion);

        Usuario usuario = crearUsuarioDesdeRegistro(registroRequest, organizacion, cliente);
        usuarioDAO.save(usuario);

        String token = jwtUtil.generateToken(
                usuario.getEmail(),
                usuario.getRol().name(),
                organizacion.getId()
        );
        return new LoginRespuestaDTO(token);
    }

    // MÉTODOS AUXILIARES

    /**
     * Crea un nuevo Usuario a partir de los datos de registro.
     * La contraseña se codifica con BCrypt antes de persistir.
     *
     * @param registroRequest datos del registro
     * @param organizacion    organización a la que pertenece el usuario
     * @param cliente         ficha de cliente vinculada al usuario
     * @return usuario listo para persistir
     */
    private Usuario crearUsuarioDesdeRegistro(RegistroRequestDTO registroRequest,
                                              Organizacion organizacion,
                                              Cliente cliente) {
        Usuario usuario = new Usuario();
        usuario.setEmail(registroRequest.getEmail());
        usuario.setPasswordHash(passwordEncoder.encode(registroRequest.getPassword()));
        usuario.setRol(RolUsuario.CLIENTE);
        usuario.setActivo(true);
        usuario.setEmailVerificado(false);
        usuario.setOrganizacion(organizacion);
        usuario.setCliente(cliente);
        return usuario;
    }

    /**
     * Busca un cliente existente por email en la organización.
     * Si existe y aún no tiene usuario vinculado, la reutiliza.
     * Si no existe crea un nuevo registro.
     */
    private Cliente resolverCliente(RegistroRequestDTO registroRequest, Organizacion organizacion) {
        Optional<Cliente> clienteExistente = clienteDAO.findByEmailAndOrganizacion(
                registroRequest.getEmail(), organizacion);

        if (clienteExistente.isPresent()) {
            Cliente cliente = clienteExistente.get();
            if (usuarioDAO.findByCliente(cliente).isEmpty()) {
                return cliente;
            }
        }

        Cliente nuevoCliente = new Cliente();
        nuevoCliente.setNombre(registroRequest.getNombre());
        nuevoCliente.setApellidos(registroRequest.getApellidos());
        nuevoCliente.setEmail(registroRequest.getEmail());
        nuevoCliente.setTelefono(registroRequest.getTelefono());
        nuevoCliente.setOrganizacion(organizacion);
        return clienteDAO.save(nuevoCliente);
    }
}
