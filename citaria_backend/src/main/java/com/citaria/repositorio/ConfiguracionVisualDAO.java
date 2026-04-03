package com.citaria.repositorio;

import com.citaria.modelo.ConfiguracionVisual;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad ConfiguracionVisual.
 */
@Repository
public interface ConfiguracionVisualDAO extends JpaRepository<ConfiguracionVisual, Integer> {
}