package com.citaria.repositorio;

import com.citaria.modelo.Servicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Servicio.
 */
@Repository
public interface ServicioDAO extends JpaRepository<Servicio, Integer> {
}