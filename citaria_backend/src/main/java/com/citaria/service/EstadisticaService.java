package com.citaria.service;

import com.citaria.dto.EstadisticaItemDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.ResumenEstadisticaDTO;
import java.time.LocalDate;
import java.util.List;

/**
 * Servicio de estadísticas.
 */
public interface EstadisticaService {

    // Resumen general
    ResumenEstadisticaDTO obtenerResumen();

    // Clientes
    List<EstadisticaMesDTO> clientesNuevosVsRecurrentes(LocalDate desde, LocalDate hasta);
    List<EstadisticaMesDTO> fidelizacionClientes(LocalDate desde, LocalDate hasta);

    // Empleados
    List<EstadisticaItemDTO> reservasPorEmpleado(LocalDate desde, LocalDate hasta);
    List<EstadisticaItemDTO> importePorEmpleado(LocalDate desde, LocalDate hasta);
    List<EstadisticaItemDTO> cancelacionesPorEmpleado(LocalDate desde, LocalDate hasta);

    // Servicios
    List<EstadisticaItemDTO> serviciosMasSolicitados(LocalDate desde, LocalDate hasta);
    List<EstadisticaItemDTO> importePorServicio(LocalDate desde, LocalDate hasta);
    List<EstadisticaItemDTO> cancelacionesPorServicio(LocalDate desde, LocalDate hasta);

}