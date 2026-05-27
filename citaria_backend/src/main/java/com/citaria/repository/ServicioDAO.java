package com.citaria.repository;

import com.citaria.model.Categoria;
import com.citaria.model.Organizacion;
import com.citaria.model.Servicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para Servicio.
 */
@Repository
public interface ServicioDAO extends JpaRepository<Servicio, Integer> {

    List<Servicio> findByOrganizacion(Organizacion organizacion);
    List<Servicio> findByCategoria(Categoria categoria);

    /**
     * Carga los servicios de una organización junto con su categoría en una sola query.
     */
    @Query("SELECT s FROM Servicio s LEFT JOIN FETCH s.categoria WHERE s.organizacion = :organizacion")
    List<Servicio> findByOrganizacionConCategoria(@Param("organizacion") Organizacion organizacion);

    /**
     * Carga los servicios de una categoría con la categoría ya inicializada.
     */
    @Query("SELECT s FROM Servicio s LEFT JOIN FETCH s.categoria WHERE s.categoria = :categoria")
    List<Servicio> findByCategoriaConCategoria(@Param("categoria") Categoria categoria);

}