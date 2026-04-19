package com.citaria.repository;

import com.citaria.model.EstadoReservaServicio;
import com.citaria.model.Reserva;
import com.citaria.model.ReservaServicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad ReservaServicio.
 */
@Repository
public interface ReservaServicioDAO extends JpaRepository<ReservaServicio, Integer> {

    List<ReservaServicio> findByReserva(Reserva reserva);

    /**
     * Cancela en bloque todas las líneas activas de una reserva.
     * Se usa en la misma transacción que la cancelación de la cabecera
     * para garantizar consistencia. Solo afecta a líneas en estado activo
     * para no sobreescribir cancelaciones individuales previas.
     *
     * @param reserva  reserva cuyas líneas se cancelan
     * @param estado   estado destino (siempre cancelado)
     */
    @Modifying
    @Query("UPDATE ReservaServicio rs SET rs.estado = :estado WHERE rs.reserva = :reserva AND rs.estado = com.citaria.model.EstadoReservaServicio.activo")
    void cancelarDetallesPorReserva(@Param("reserva") Reserva reserva,
                                    @Param("estado") EstadoReservaServicio estado);
}