package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.EstadoReserva;
import com.citaria.model.Organizacion;
import com.citaria.model.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repositorio para la entidad Reserva.
 */
@Repository
public interface ReservaDAO extends JpaRepository<Reserva, Integer> {

    List<Reserva> findByOrganizacion(Organizacion organizacion);
    List<Reserva> findByCliente(Cliente cliente);
    List<Reserva> findByOrganizacionAndFecha(Organizacion organizacion, LocalDate fecha);
    List<Reserva> findByOrganizacionAndEstado(Organizacion organizacion, EstadoReserva estado);

}