package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.Habilidad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para Habilidad.
 */
@Repository
public interface HabilidadDAO extends JpaRepository<Habilidad, Integer> {

    List<Habilidad> findByOrganizacion(Organizacion organizacion);

}