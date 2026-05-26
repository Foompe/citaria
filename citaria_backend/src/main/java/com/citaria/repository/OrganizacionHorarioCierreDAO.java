package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorarioCierre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para OrganizacionHorarioCierre.
 */
@Repository
public interface OrganizacionHorarioCierreDAO extends JpaRepository<OrganizacionHorarioCierre, Integer> {

    List<OrganizacionHorarioCierre> findByOrganizacion(Organizacion organizacion);
    List<OrganizacionHorarioCierre> findByOrganizacionAndFechaBetween(Organizacion organizacion, LocalDate fechaInicio, LocalDate fechaFin);
    Optional<OrganizacionHorarioCierre> findByOrganizacionAndFecha(Organizacion organizacion, LocalDate fecha);

}