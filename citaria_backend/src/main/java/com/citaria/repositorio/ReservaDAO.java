package com.citaria.repositorio;

import com.citaria.modelo.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Reserva.
 */
@Repository
public interface ReservaDAO extends JpaRepository<Reserva, Integer> {
}