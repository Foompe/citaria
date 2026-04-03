package com.citaria.repositorio;

import com.citaria.modelo.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Organizacion.
 */
@Repository
public interface OrganizacionDAO extends JpaRepository<Organizacion, Integer> {
}