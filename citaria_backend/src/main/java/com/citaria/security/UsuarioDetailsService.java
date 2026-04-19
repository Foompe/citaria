package com.citaria.security;

import com.citaria.model.Organizacion;
import com.citaria.model.Usuario;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.UsuarioDAO;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Implementación de UserDetailsService de Spring Security.
 * Usa un username compuesto "email:organizacionId" para identificar
 * unívocamente a un usuario cuando el mismo email puede existir
 * en múltiples organizaciones.
 */
@Service
public class UsuarioDetailsService implements UserDetailsService {

    static final String SEPARADOR_USERNAME = ":";

    private final UsuarioDAO usuarioDAO;
    private final OrganizacionDAO organizacionDAO;

    public UsuarioDetailsService(UsuarioDAO usuarioDAO, OrganizacionDAO organizacionDAO) {
        this.usuarioDAO = usuarioDAO;
        this.organizacionDAO = organizacionDAO;
    }

    /**
     * Carga el usuario por username compuesto "email:organizacionId".
     * El separador ':' es seguro porque no puede aparecer en un email RFC 5321 válido.
     *
     * @param usernameCompuesto formato "email:organizacionId"
     * @return UserDetails con el estado del usuario
     * @throws UsernameNotFoundException si el formato es inválido o el usuario no existe
     */
    @Override
    public UserDetails loadUserByUsername(String usernameCompuesto) throws UsernameNotFoundException {
        String[] partes = usernameCompuesto.split(SEPARADOR_USERNAME, 2);
        if (partes.length != 2) {
            throw new UsernameNotFoundException("Formato de username inválido");
        }

        String email = partes[0];
        Integer organizacionId;
        try {
            organizacionId = Integer.parseInt(partes[1]);
        } catch (NumberFormatException ex) {
            throw new UsernameNotFoundException("Formato de organizacionId inválido");
        }

        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Organización no encontrada"));

        Usuario usuario = usuarioDAO.findByEmailAndOrganizacion(email, organizacion)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Usuario no encontrado"));

        return User.withUsername(usernameCompuesto)
                .password(usuario.getPasswordHash())
                .authorities(List.of(new SimpleGrantedAuthority("ROLE_" + usuario.getRol().name())))
                .disabled(!usuario.getActivo())
                .build();
    }

    /**
     * Construye el username compuesto a partir de email y organizacionId.
     * Método utilitario para uso en AuthServiceImpl y JwtFilter.
     */
    public static String construirUsername(String email, Integer organizacionId) {
        return email + SEPARADOR_USERNAME + organizacionId;
    }
}