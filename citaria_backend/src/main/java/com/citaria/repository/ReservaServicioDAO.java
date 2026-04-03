package com.citaria.repository;

import com.citaria.model.Reserva;
import com.citaria.model.ReservaServicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad ReservaServicio.
 */
@Repository
public interface ReservaServicioDAO extends JpaRepository<ReservaServicio, Integer> {

    List<ReservaServicio> findByReserva(Reserva reserva);

}