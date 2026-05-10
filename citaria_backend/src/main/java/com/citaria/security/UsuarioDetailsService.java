package com.citaria.security;

import com.citaria.model.Organizacion;
import com.citaria.model.Usuario;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.UsuarioDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación de UserDetailsService de Spring Security.
 */
@Service
public class UsuarioDetailsService implements UserDetailsService {

    static final String SEPARADOR_USERNAME = ":";
    private final UsuarioDAO usuarioDAO;
    private final OrganizacionDAO organizacionDAO;

    @Autowired
    public UsuarioDetailsService(UsuarioDAO usuarioDAO, OrganizacionDAO organizacionDAO) {
        this.usuarioDAO = usuarioDAO;
        this.organizacionDAO = organizacionDAO;
    }

    /**
     * Carga el usuario por username compuesto "email:organizacionId".
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

        Optional<Organizacion> organizacionOptional = organizacionDAO.findById(organizacionId);
        if (organizacionOptional.isEmpty()) {
            throw new UsernameNotFoundException("Organización no encontrada");
        }
        Organizacion organizacion = organizacionOptional.get();

        Optional<Usuario> usuarioOptional = usuarioDAO.findByEmailAndOrganizacion(email, organizacion);
        if (usuarioOptional.isEmpty()) {
            throw new UsernameNotFoundException("Usuario no encontrado");
        }
        Usuario usuario = usuarioOptional.get();

        List<SimpleGrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_" + usuario.getRol().name()));

        return User.withUsername(usernameCompuesto)
                .password(usuario.getPasswordHash())
                .authorities(authorities)
                .disabled(!usuario.getActivo())
                .build();
    }

    //  Método auxiliar
    public static String construirUsername(String email, Integer organizacionId) {
        return email + SEPARADOR_USERNAME + organizacionId;
    }
}
