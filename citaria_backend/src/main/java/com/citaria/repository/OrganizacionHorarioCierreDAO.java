package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorarioCierre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad OrganizacionHorarioCierre.
 */
@Repository
public interface OrganizacionHorarioCierreDAO extends JpaRepository<OrganizacionHorarioCierre, Integer> {

    List<OrganizacionHorarioCierre> findByOrganizacion(Organizacion organizacion);

}