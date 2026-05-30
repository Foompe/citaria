package com.citaria.repository;

import com.citaria.model.Servicio;
import com.citaria.model.ServicioHabilidad;
import com.citaria.model.ServicioHabilidadId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para ServicioHabilidad.
 */
@Repository
public interface ServicioHabilidadDAO extends JpaRepository<ServicioHabilidad, ServicioHabilidadId> {

    List<ServicioHabilidad> findByServicio(Servicio servicio);

    /**
     * Devuelve los ids de habilidades requeridas por una lista de servicios.
     */
    @Query("SELECT DISTINCT ss.habilidad.id FROM ServicioHabilidad ss WHERE ss.servicio.id IN :servicioIds")
    List<Integer> obtenerHabilidadIdsRequeridas(@Param("servicioIds") List<Integer> servicioIds);
}