package com.citaria.repositorio;

import com.citaria.modelo.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Cliente.
 */
@Repository
public interface ClienteDAO extends JpaRepository<Cliente, Integer> {
}