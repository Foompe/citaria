package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para Cliente.
 */
@Repository
public interface ClienteDAO extends JpaRepository<Cliente, Integer> {

    List<Cliente> findByOrganizacion(Organizacion organizacion);
    List<Cliente> findByTelefonoAndOrganizacion(String telefono, Organizacion organizacion);
    Optional<Cliente> findByEmailAndOrganizacion(String email, Organizacion organizacion);
    Optional<Cliente> findByDniAndOrganizacion(String dni, Organizacion organizacion);

}