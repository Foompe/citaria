package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para OrganizacionHorario.
 */
@Repository
public interface OrganizacionHorarioDAO extends JpaRepository<OrganizacionHorario, Integer> {

    List<OrganizacionHorario> findByOrganizacion(Organizacion organizacion);
    List<OrganizacionHorario> findByOrganizacionAndActivo(Organizacion organizacion, Boolean activo);
    Optional<OrganizacionHorario> findByOrganizacionAndDiaSemanaAndActivo(Organizacion organizacion, Integer diaSemana, Boolean activo);

}