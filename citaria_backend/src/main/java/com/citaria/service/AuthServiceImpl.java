package com.citaria.service;

import com.citaria.dto.LoginRequestDTO;
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
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Implementación del servicio de autenticación.
 *
 * El login delega la verificación al {@link AuthenticationManager} usando el username
 * compuesto (email:organizacionId) para identificar unívocamente al usuario.
 * El registro gestiona la vinculación automática con fichas de cliente existentes.
 */
@Service
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final UsuarioDAO usuarioDAO;
    private final OrganizacionDAO organizacionDAO;
    private final ClienteDAO clienteDAO;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

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

    /**
     * {@inheritDoc}
     *
     * Construye el username compuesto antes de delegar en el AuthenticationManager,
     * que internamente usa UsuarioDetailsService para cargar el usuario correcto
     * cuando el mismo email existe en varias organizaciones.
     */
    @Override
    @Transactional(readOnly = true)
    public LoginRespuestaDTO login(LoginRequestDTO loginRequest) {
        Organizacion organizacion = organizacionDAO.findById(loginRequest.getOrganizacionId())
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización no encontrada"));

        String usernameCompuesto = UsuarioDetailsService.construirUsername(
                loginRequest.getEmail(), organizacion.getId());

        Authentication autenticacion = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        usernameCompuesto,
                        loginRequest.getPassword()
                )
        );

        UserDetails usuarioDetails = (UserDetails) autenticacion.getPrincipal();

        Usuario usuario = usuarioDAO.findByEmailAndOrganizacion(
                        loginRequest.getEmail(), organizacion)
                .orElseThrow(() -> new IllegalStateException(
                        "Inconsistencia interna: usuario autenticado no encontrado en BD"));

        String token = jwtUtil.generateToken(
                usuario.getEmail(),
                usuario.getRol().name(),
                organizacion.getId()
        );
        return new LoginRespuestaDTO(token);
    }

    /**
     * {@inheritDoc}
     *
     * Busca la organización por tokenRegistro opaco — el cliente nunca conoce
     * el id interno de la organización. Si el email coincide con una ficha de
     * cliente existente se vincula para preservar el historial de reservas previas.
     */
    @Override
    @Transactional
    public LoginRespuestaDTO registro(RegistroRequestDTO registroRequest) {
        Organizacion organizacion = organizacionDAO.findByTokenRegistro(
                        registroRequest.getTokenRegistro())
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Token de registro inválido"));

        if (usuarioDAO.existsByEmailAndOrganizacion(registroRequest.getEmail(), organizacion)) {
            throw new EmailYaRegistradoException(
                    "El email ya está registrado en el sistema");
        }

        Cliente cliente = resolverCliente(registroRequest, organizacion);

        Usuario usuario = new Usuario();
        usuario.setEmail(registroRequest.getEmail());
        usuario.setPasswordHash(passwordEncoder.encode(registroRequest.getPassword()));
        usuario.setRol(RolUsuario.CLIENTE);
        usuario.setActivo(true);
        usuario.setEmailVerificado(false);
        usuario.setOrganizacion(organizacion);
        usuario.setCliente(cliente);
        usuarioDAO.save(usuario);

        String token = jwtUtil.generateToken(
                usuario.getEmail(),
                usuario.getRol().name(),
                organizacion.getId()
        );
        return new LoginRespuestaDTO(token);
    }

    /**
     * Busca una ficha de cliente existente por email en la organización.
     * Si existe y aún no tiene usuario vinculado, la reutiliza para preservar
     * el historial de reservas creadas por el admin antes del registro.
     * Si no existe crea una nueva ficha con los datos del registro.
     */
    private Cliente resolverCliente(RegistroRequestDTO registroRequest, Organizacion organizacion) {
        Optional<Cliente> clienteExistente = clienteDAO.findByEmailAndOrganizacion(
                registroRequest.getEmail(), organizacion);

        if (clienteExistente.isPresent()) {
            return clienteExistente.get();
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