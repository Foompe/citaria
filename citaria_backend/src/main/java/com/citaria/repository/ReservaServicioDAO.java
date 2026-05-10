package com.citaria.repository;

import com.citaria.model.EstadoReservaServicio;
import com.citaria.model.Reserva;
import com.citaria.model.ReservaServicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * Repositorio para ReservaServicio.
 */
@Repository
public interface ReservaServicioDAO extends JpaRepository<ReservaServicio, Integer> {

    List<ReservaServicio> findByReserva(Reserva reserva);

    /**
     * Cancela en bloque todas las líneas activas de una reserva.
     */
    @Modifying
    @Query("UPDATE ReservaServicio rs SET rs.estado = :estado " +
            "WHERE rs.reserva = :reserva AND rs.estado = com.citaria.model.EstadoReservaServicio.activo")
    void cancelarDetallesPorReserva(@Param("reserva") Reserva reserva,
                                    @Param("estado") EstadoReservaServicio estado);

    /**
     * Detecta si un empleado tiene alguna línea activa que solape con la franja indicada.
     */
    @Query("SELECT COUNT(rs) FROM ReservaServicio rs WHERE rs.empleado.id = :empleadoId " +
            "AND rs.reserva.fecha = :fecha AND rs.estado = com.citaria.model.EstadoReservaServicio.activo " +
            "AND rs.horaInicio < :horaFin AND rs.horaFin > :horaInicio")
    long contarSolapamientos(@Param("empleadoId") Integer empleadoId, @Param("fecha") LocalDate fecha,
                             @Param("horaInicio") LocalTime horaInicio, @Param("horaFin") LocalTime horaFin);

    /**
     * Cuenta las reservas activas de un empleado en una fecha concreta.
     */
    @Query("SELECT COUNT(rs) FROM ReservaServicio rs WHERE rs.empleado.id = :empleadoId " +
            "AND rs.reserva.fecha = :fecha AND rs.estado = com.citaria.model.EstadoReservaServicio.activo")
    long contarReservasPorEmpleadoYFecha(@Param("empleadoId") Integer empleadoId, @Param("fecha") LocalDate fecha);
}