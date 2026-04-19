package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.EstadoReserva;

import java.time.LocalDate;
import java.util.List;

/**
 * Contrato del servicio de gestión de reservas.
 * Incluye gestión de líneas de detalle de cada reserva.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 */
public interface ReservaService {

    // Reserva
    List<ReservaDTO> obtenerTodas();
    List<ReservaDTO> obtenerPorCliente(Integer clienteId);
    List<ReservaDTO> obtenerPorFecha(LocalDate fecha);
    List<ReservaDTO> obtenerPorEstado(EstadoReserva estado);
    ReservaDTO obtenerPorId(Integer id);
    ReservaDTO crear(Integer clienteId, ReservaDTO dto);
    ReservaDTO actualizarEstado(Integer id, EstadoReserva estado);

    /**
     * Cancela una reserva y todas sus líneas de detalle activas en una sola transacción.
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     */
    void eliminar(Integer id);

    // Líneas de detalle
    List<ReservaServicioDTO> obtenerDetallesPorReserva(Integer reservaId);
    ReservaServicioDTO agregarDetalle(Integer reservaId, ReservaServicioDTO dto);

    /**
     * Cancela una línea de detalle individual sin afectar al resto de la reserva.
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     */
    void eliminarDetalle(Integer id);
}