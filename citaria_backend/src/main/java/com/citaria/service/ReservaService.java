package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.EstadoReserva;

import java.time.LocalDate;
import java.util.List;

/**
 * Contrato del servicio de gestión de reservas.
 * Incluye gestión de líneas de detalle de cada reserva.
 */
public interface ReservaService {

    // Reserva
    List<ReservaDTO> obtenerTodas(Integer organizacionId);
    List<ReservaDTO> obtenerPorCliente(Integer clienteId);
    List<ReservaDTO> obtenerPorFecha(Integer organizacionId, LocalDate fecha);
    List<ReservaDTO> obtenerPorEstado(Integer organizacionId, EstadoReserva estado);
    ReservaDTO obtenerPorId(Integer id);
    ReservaDTO crear(Integer organizacionId, Integer clienteId, ReservaDTO dto);
    ReservaDTO actualizarEstado(Integer id, EstadoReserva estado);
    boolean eliminar(Integer id);

    // Líneas de detalle
    List<ReservaServicioDTO> obtenerDetallesPorReserva(Integer reservaId);
    ReservaServicioDTO agregarDetalle(Integer reservaId, ReservaServicioDTO dto);
    boolean eliminarDetalle(Integer id);
}