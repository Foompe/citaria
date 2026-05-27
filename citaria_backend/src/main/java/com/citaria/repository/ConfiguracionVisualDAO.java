package com.citaria.repository;

import com.citaria.model.ConfiguracionVisual;
import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio para ConfiguracionVisual.
 */
@Repository
public interface ConfiguracionVisualDAO extends JpaRepository<ConfiguracionVisual, Integer> {

    Optional<ConfiguracionVisual> findByOrganizacion(Organizacion organizacion);

    /**
     * Carga en batch las configuraciones visuales de una lista de organizaciones.
     */
    @Query("SELECT c FROM ConfiguracionVisual c WHERE c.organizacion IN :organizaciones")
    List<ConfiguracionVisual> findByOrganizacionIn(@Param("organizaciones") List<Organizacion> organizaciones);

}