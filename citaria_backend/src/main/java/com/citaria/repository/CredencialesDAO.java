package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.Credenciales;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la entidad Credenciales.
 */
@Repository
public interface CredencialesDAO extends JpaRepository<Credenciales, Integer> {

    Optional<Credenciales> findByCliente(Cliente cliente);

}