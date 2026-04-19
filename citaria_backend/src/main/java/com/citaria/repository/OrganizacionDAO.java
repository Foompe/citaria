package com.citaria.repository;

import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la entidad Organizacion.
 */
@Repository
public interface OrganizacionDAO extends JpaRepository<Organizacion, Integer> {

    Optional<Organizacion> findByTokenRegistro(String tokenRegistro);
}