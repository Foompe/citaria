package com.citaria.security;

import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Organizacion;
import com.citaria.model.Usuario;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.UsuarioDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import java.util.Optional;

/**
 * Componente central para acceder al usuario y organización autenticados.
 * Encapsula la lectura del SecurityContextHolder para que los servicios
 * no dependan directamente de la infraestructura de Spring Security.
 *
 * El organizacionId se extrae del username compuesto del token (email:organizacionId),
 * evitando una consulta extra a BD en cada petición.
 */
@Component
public class ContextoSeguridad {

    private final OrganizacionDAO organizacionDAO;
    private final UsuarioDAO usuarioDAO;

    @Autowired
    public ContextoSeguridad(OrganizacionDAO organizacionDAO, UsuarioDAO usuarioDAO) {
        this.organizacionDAO = organizacionDAO;
        this.usuarioDAO = usuarioDAO;
    }

    /**
     * Devuelve la organización del usuario autenticado en la petición actual.
     * Se extrae directamente del username compuesto del token.
     *
     * @return devuelve la organización del usuario
     */
    public Organizacion obtenerOrganizacionActual() {
        Integer organizacionId = extraerOrganizacionId();
        Optional<Organizacion> organizacionOptional = organizacionDAO.findById(organizacionId);
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException(
                    "Organización del usuario autenticado no encontrada");
        }
        return organizacionOptional.get();
    }

    /**
     * Devuelve el usuario autenticado.
     *
     * @return usuario autenticado
     */
    public Usuario obtenerUsuarioActual() {
        String[] partes = extraerPartes();
        String email = partes[0];
        Integer organizacionId = Integer.parseInt(partes[1]);

        Optional<Organizacion> organizacionOptional = organizacionDAO.findById(organizacionId);
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException(
                    "Organización del usuario autenticado no encontrada");
        }
        Organizacion organizacion = organizacionOptional.get();

        Optional<Usuario> usuarioOptional = usuarioDAO.findByEmailAndOrganizacion(email, organizacion);
        if (usuarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException(
                    "Usuario autenticado no encontrado");
        }
        return usuarioOptional.get();
    }

    /**
     * Devuelve el id de organización del usuario autenticado directamente del token sin tener que consultar la BD.
     */
    public Integer obtenerOrganizacionIdActual() {
        return extraerOrganizacionId();
    }

    /**
     * Devuelve el id del cliente vinculado al usuario autenticado.
     *
     * @return devuelve el id del cliente vinculado
     * @throws IllegalStateException si el usuario autenticado no tiene cliente vinculado
     */
    public Integer obtenerClienteIdActual() {
        Usuario usuario = obtenerUsuarioActual();
        if (usuario.getCliente() == null) {
            throw new IllegalStateException("El usuario autenticado no tiene cliente vinculado");
        }
        return usuario.getCliente().getId();
    }


    //  Métodos auxiliares


    private Integer extraerOrganizacionId() {
        return Integer.parseInt(extraerPartes()[1]);
    }

    private String[] extraerPartes() {
        Authentication autenticacion = SecurityContextHolder.getContext().getAuthentication();
        if (autenticacion == null || !autenticacion.isAuthenticated()) {
            throw new IllegalStateException("No hay usuario autenticado en el contexto actual");
        }
        UserDetails userDetails = (UserDetails) autenticacion.getPrincipal();
        return userDetails.getUsername().split(UsuarioDetailsService.SEPARADOR_USERNAME, 2);
    }
}
