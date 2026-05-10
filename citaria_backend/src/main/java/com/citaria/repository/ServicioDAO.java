package com.citaria.repository;

import com.citaria.model.Categoria;
import com.citaria.model.Organizacion;
import com.citaria.model.Servicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para Servicio.
 */
@Repository
public interface ServicioDAO extends JpaRepository<Servicio, Integer> {

    List<Servicio> findByOrganizacion(Organizacion organizacion);
    List<Servicio> findByCategoria(Categoria categoria);

}