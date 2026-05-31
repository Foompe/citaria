package com.citaria.service;

import com.citaria.model.EstadoReserva;
import com.citaria.model.EstadoReservaServicio;
import com.citaria.model.Reserva;
import com.citaria.repository.ReservaDAO;
import com.citaria.repository.ReservaServicioDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Tarea diaria que cierra reservas cuya fecha ya ha pasado.
 * - confirmada → completada
 * - pendiente  → cancelada
 * Se ejecuta cada día a las 02:00.
 */
@Component
public class TareaExpiracionReservas {

    private final ReservaDAO reservaDAO;
    private final ReservaServicioDAO reservaServicioDAO;

    @Autowired
    public TareaExpiracionReservas(ReservaDAO reservaDAO, ReservaServicioDAO reservaServicioDAO) {
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
    }

    @Scheduled(cron = "0 0 2 * * *")
    @Transactional
    public void expirarReservasPasadas() {
        LocalDate hoy = LocalDate.now();

        List<Reserva> confirmadas = reservaDAO.findByFechaBeforeAndEstadoIn(
                hoy, List.of(EstadoReserva.confirmada));
        for (Reserva r : confirmadas) {
            r.setEstado(EstadoReserva.completada);
            reservaDAO.save(r);
        }

        List<Reserva> pendientes = reservaDAO.findByFechaBeforeAndEstadoIn(
                hoy, List.of(EstadoReserva.pendiente));
        for (Reserva r : pendientes) {
            r.setEstado(EstadoReserva.cancelada);
            reservaServicioDAO.cancelarDetallesPorReserva(r, EstadoReservaServicio.cancelado);
            reservaDAO.save(r);
        }
    }
}
