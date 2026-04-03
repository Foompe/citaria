package com.citaria.repositorio;

import com.citaria.modelo.Credenciales;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Credenciales.
 */
@Repository
public interface CredencialesDAO extends JpaRepository<Credenciales, Integer> {
}