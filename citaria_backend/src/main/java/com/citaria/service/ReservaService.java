package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.EstadoReserva;
import java.time.LocalDate;
import java.util.List;

/**
 * Servicio de gestión de reservas y lineas de reserva.
 */
public interface ReservaService {

    // Reserva
    List<ReservaDTO> obtenerTodas();
    List<ReservaDTO> obtenerPorCliente(Integer clienteId);
    List<ReservaDTO> obtenerPorFecha(LocalDate fecha);
    List<ReservaDTO> obtenerPorEstado(EstadoReserva estado);
    List<ReservaDTO> obtenerPorFechaYEstados(LocalDate fecha, List<EstadoReserva> estados);
    ReservaDTO obtenerPorId(Integer id);
    ReservaDTO crear(Integer clienteId, ReservaDTO dto);
    ReservaDTO actualizarEstado(Integer id, EstadoReserva estado);
    void cancelar(Integer id, String motivo);

    // Líneas de detalle
    List<ReservaServicioDTO> obtenerLineasPorReserva(Integer reservaId);
    ReservaServicioDTO agregarLineaAReserva(Integer reservaId, ReservaServicioDTO dto);
    void eliminarLinea(Integer reservaId, Integer detalleId);
    ReservaServicioDTO reasignarEmpleadoDetalle(Integer reservaId, Integer detalleId, Integer nuevoEmpleadoId);

}