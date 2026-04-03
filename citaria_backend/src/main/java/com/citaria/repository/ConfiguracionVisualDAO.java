package com.citaria.repository;

import com.citaria.model.ConfiguracionVisual;
import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la entidad ConfiguracionVisual.
 */
@Repository
public interface ConfiguracionVisualDAO extends JpaRepository<ConfiguracionVisual, Integer> {

    Optional<ConfiguracionVisual> findByOrganizacion(Organizacion organizacion);

}