package com.citaria.service;

import com.citaria.dto.DiasDisponiblesDTO;
import com.citaria.dto.DisponibilidadDTO;
import com.citaria.dto.PeriodoDisponiblesDTO;
import java.time.LocalDate;
import java.util.List;

/**
 * Servicio de disponibilidad.
 * Calcula las franjas horarias disponibles para una fecha y lista de servicios,
 * teniendo en cuenta el horario del negocio, el horario del empleado y las
 * reservas existentes.
 */
public interface DisponibilidadService {

    /**
     * Devuelve las franjas horarias disponibles en la fecha indicada para los
     * servicios seleccionados, en intervalos de 15 minutos desde la apertura
     * del negocio hasta (cierre - duración total de los servicios).
     *
     *      Si se indica empleadoId, filtra solo ese empleado.
     *      Si no se indica, evalúa todos los empleados con las skills requeridas.
     *
     * @param fecha       fecha a consultar
     * @param servicioIds lista de ids de servicios seleccionados
     * @param empleadoId  id del empleado (opcional)
     * @return disponibilidad con la lista de franjas y su estado
     */
    DisponibilidadDTO obtenerDisponibilidad(LocalDate fecha,
                                            List<Integer> servicioIds,
                                            Integer empleadoId);

    /**
     * Devuelve los días del mes indicado que tienen al menos una franja disponible.
     *
     * @param anio        año a consultar
     * @param mes         mes a consultar (1-12)
     * @param servicioIds lista de ids de servicios seleccionados
     * @param empleadoId  id del empleado (opcional)
     * @return lista de números de día del mes con disponibilidad
     */
    DiasDisponiblesDTO obtenerDiasDisponibles(Integer anio,
                                              Integer mes,
                                              List<Integer> servicioIds,
                                              Integer empleadoId);

    PeriodoDisponiblesDTO obtenerDiasDisponiblesPeriodo(LocalDate fechaInicio,
                                                        LocalDate fechaFin,
                                                        List<Integer> servicioIds,
                                                        Integer empleadoId);
}
