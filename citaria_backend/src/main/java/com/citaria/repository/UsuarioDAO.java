package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import com.citaria.model.RolUsuario;
import com.citaria.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para Usuario.
 */
@Repository
public interface UsuarioDAO extends JpaRepository<Usuario, Integer> {

    Optional<Usuario> findByEmailAndOrganizacion(String email, Organizacion organizacion);
    List<Usuario> findByOrganizacion(Organizacion organizacion);
    List<Usuario> findByOrganizacionAndRol(Organizacion organizacion, RolUsuario rol);
    List<Usuario> findByClienteIn(List<Cliente> clientes);
    boolean existsByEmailAndOrganizacion(String email, Organizacion organizacion);
    Optional<Usuario> findByCliente(Cliente cliente);

}
