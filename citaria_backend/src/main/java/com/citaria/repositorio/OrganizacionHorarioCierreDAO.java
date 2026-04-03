package com.citaria.repositorio;

import com.citaria.modelo.OrganizacionHorarioCierre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad OrganizacionHorarioCierre.
 */
@Repository
public interface OrganizacionHorarioCierreDAO extends JpaRepository<OrganizacionHorarioCierre, Integer> {
}