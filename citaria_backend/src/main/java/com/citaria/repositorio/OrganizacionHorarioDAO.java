package com.citaria.repositorio;

import com.citaria.modelo.OrganizacionHorario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad OrganizacionHorario.
 */
@Repository
public interface OrganizacionHorarioDAO extends JpaRepository<OrganizacionHorario, Integer> {
}