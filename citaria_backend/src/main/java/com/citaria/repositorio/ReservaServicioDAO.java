package com.citaria.repositorio;

import com.citaria.modelo.ReservaServicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad ReservaServicio.
 */
@Repository
public interface ReservaServicioDAO extends JpaRepository<ReservaServicio, Integer> {
}