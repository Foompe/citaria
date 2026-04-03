package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad OrganizacionHorario.
 */
@Repository
public interface OrganizacionHorarioDAO extends JpaRepository<OrganizacionHorario, Integer> {

    List<OrganizacionHorario> findByOrganizacion(Organizacion organizacion);

}