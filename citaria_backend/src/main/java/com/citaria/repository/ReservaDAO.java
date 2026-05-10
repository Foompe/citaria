package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.Empleado;
import com.citaria.model.EstadoReserva;
import com.citaria.model.Organizacion;
import com.citaria.model.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

/**
 * Repositorio para Reserva.
 */
@Repository
public interface ReservaDAO extends JpaRepository<Reserva, Integer> {

    List<Reserva> findByOrganizacion(Organizacion organizacion);
    List<Reserva> findByCliente(Cliente cliente);
    List<Reserva> findByOrganizacionAndFecha(Organizacion organizacion, LocalDate fecha);
    List<Reserva> findByOrganizacionAndEstado(Organizacion organizacion, EstadoReserva estado);

    /** Reservas futuras activas que tienen alguna línea asignada al empleado. */
    @Query("SELECT DISTINCT rs.reserva FROM ReservaServicio rs WHERE rs.empleado = :empleado " +
            "AND rs.reserva.fecha >= :hoy AND rs.reserva.estado IN :estados")
    List<Reserva> findReservasFuturasActivasPorEmpleado(
            @Param("empleado") Empleado empleado,
            @Param("hoy") LocalDate hoy,
            @Param("estados") List<EstadoReserva> estados);

    /** Reservas futuras de cliente por estado. */
    @Query("SELECT r FROM Reserva r WHERE r.cliente = :cliente AND r.fecha >= :hoy AND r.estado IN :estados")
    List<Reserva> findReservasFuturasActivasPorCliente(
            @Param("cliente") Cliente cliente,
            @Param("hoy") LocalDate hoy,
            @Param("estados") List<EstadoReserva> estados);

    /** Reservas de una organización por fecha y por estado */
    @Query("SELECT r FROM Reserva r WHERE r.organizacion = :organizacion AND r.fecha = :fecha AND r.estado IN :estados")
    List<Reserva> findByOrganizacionAndFechaAndEstadoIn(
            @Param("organizacion") Organizacion organizacion,
            @Param("fecha") LocalDate fecha,
            @Param("estados") List<EstadoReserva> estados);
}