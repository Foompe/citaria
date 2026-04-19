package com.citaria.service;

import com.citaria.dto.EstadisticaEmpleadoDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.EstadisticaServicioDTO;

import java.time.LocalDate;
import java.util.List;

/**
 * Contrato del servicio de estadísticas.
 * Todas las métricas se filtran automáticamente por la organización
 * del usuario autenticado a través del contexto de seguridad.
 */
public interface EstadisticaService {

    // Clientes
    List<EstadisticaMesDTO> clientesNuevosVsRecurrentes(LocalDate desde, LocalDate hasta);
    List<EstadisticaMesDTO> fidelizacionClientes(LocalDate desde, LocalDate hasta);

    // Empleados
    List<EstadisticaEmpleadoDTO> reservasPorEmpleado(LocalDate desde, LocalDate hasta);
    List<EstadisticaEmpleadoDTO> importePorEmpleado(LocalDate desde, LocalDate hasta);
    List<EstadisticaEmpleadoDTO> cancelacionesPorEmpleado(LocalDate desde, LocalDate hasta);

    // Servicios
    List<EstadisticaServicioDTO> serviciosMasSolicitados(LocalDate desde, LocalDate hasta);
    List<EstadisticaServicioDTO> importePorServicio(LocalDate desde, LocalDate hasta);
    List<EstadisticaServicioDTO> cancelacionesPorServicio(LocalDate desde, LocalDate hasta);
}