package com.citaria.security;

import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.Organizacion;
import com.citaria.model.Usuario;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.UsuarioDAO;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

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

    public ContextoSeguridad(OrganizacionDAO organizacionDAO, UsuarioDAO usuarioDAO) {
        this.organizacionDAO = organizacionDAO;
        this.usuarioDAO = usuarioDAO;
    }

    /**
     * Devuelve la organización del usuario autenticado en la petición actual.
     * El id de organización se extrae directamente del username compuesto del token
     * sin consulta adicional a BD para resolver el id.
     *
     * @return organización del usuario autenticado
     */
    public Organizacion obtenerOrganizacionActual() {
        Integer organizacionId = extraerOrganizacionId();
        return organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización del usuario autenticado no encontrada"));
    }

    /**
     * Devuelve el usuario autenticado en la petición actual.
     *
     * @return usuario autenticado
     */
    public Usuario obtenerUsuarioActual() {
        String[] partes = extraerPartes();
        String email = partes[0];
        Integer organizacionId = Integer.parseInt(partes[1]);

        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización del usuario autenticado no encontrada"));

        return usuarioDAO.findByEmailAndOrganizacion(email, organizacion)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Usuario autenticado no encontrado"));
    }

    /**
     * Devuelve el id de organización del usuario autenticado.
     * Extracción directa del token sin consulta a BD.
     */
    public Integer obtenerOrganizacionIdActual() {
        return extraerOrganizacionId();
    }

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