package com.citaria.service;

import com.citaria.dto.EstadisticaEmpleadoDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.EstadisticaServicioDTO;
import com.citaria.repository.EstadisticaDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Implementación del servicio de estadísticas.
 * Delega las queries agregadas al EstadisticaDAO y transforma
 * los resultados en DTOs listos para consumir desde el frontend.
 * El campo periodo devuelve formato "YYYY-MM" — la etiqueta legible
 * la construye el frontend según su locale.
 */
@Service
public class EstadisticaServiceImpl implements EstadisticaService {

    private final EstadisticaDAO estadisticaDAO;
    private final ContextoSeguridad contextoSeguridad;

    public EstadisticaServiceImpl(EstadisticaDAO estadisticaDAO,
                                  ContextoSeguridad contextoSeguridad) {
        this.estadisticaDAO = estadisticaDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    // ===== CLIENTES =====

    /**
     * {@inheritDoc}
     *
     * Combina los resultados de dos queries (nuevos y recurrentes) indexando
     * por período para garantizar que todos los meses del rango aparecen
     * en la respuesta aunque no haya clientes nuevos o recurrentes ese mes.
     * valor1=nuevos, valor2=recurrentes
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaMesDTO> clientesNuevosVsRecurrentes(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();

        List<Object[]> nuevos = estadisticaDAO.contarClientesNuevosPorMes(organizacionId, desde, hasta);
        List<Object[]> recurrentes = estadisticaDAO.contarClientesRecurrentesPorMes(organizacionId, desde, hasta);

        Map<String, Double> mapaRecurrentes = recurrentes.stream()
                .collect(Collectors.toMap(
                        row -> (String) row[0],
                        row -> ((Number) row[1]).doubleValue()
                ));

        List<EstadisticaMesDTO> resultado = new ArrayList<>();
        for (Object[] fila : nuevos) {
            String periodo = (String) fila[0];
            Double cantidadNuevos = ((Number) fila[1]).doubleValue();
            Double cantidadRecurrentes = mapaRecurrentes.getOrDefault(periodo, 0.0);
            resultado.add(new EstadisticaMesDTO(periodo, cantidadNuevos, cantidadRecurrentes));
        }
        return resultado;
    }

    /**
     * {@inheritDoc}
     * valor1=totalClientes, valor2=porcentajeRetencion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaMesDTO> fidelizacionClientes(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.calcularFidelizacionPorMes(organizacionId, desde, hasta);

        List<EstadisticaMesDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            String periodo = (String) fila[0];
            Double totalClientes = ((Number) fila[1]).doubleValue();
            Double repiten = ((Number) fila[2]).doubleValue();
            double porcentaje = totalClientes > 0 ? (repiten / totalClientes) * 100 : 0.0;
            resultado.add(new EstadisticaMesDTO(
                    periodo,
                    totalClientes,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    // ===== EMPLEADOS =====

    /**
     * {@inheritDoc}
     * valor=totalReservas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaEmpleadoDTO> reservasPorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.reservasPorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaEmpleadoDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            Double total = ((Number) fila[2]).doubleValue();
            Double canceladas = ((Number) fila[3]).doubleValue();
            double porcentajeCancelacion = total > 0 ? (canceladas / total) * 100 : 0.0;
            resultado.add(new EstadisticaEmpleadoDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    total,
                    Math.round(porcentajeCancelacion * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    /**
     * {@inheritDoc}
     * valor=importeTotal, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaEmpleadoDTO> importePorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.importePorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaEmpleadoDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            resultado.add(new EstadisticaEmpleadoDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    ((Number) fila[2]).doubleValue(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * {@inheritDoc}
     * valor=totalCanceladas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaEmpleadoDTO> cancelacionesPorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.cancelacionesPorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaEmpleadoDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            Double total = ((Number) fila[2]).doubleValue();
            Double canceladas = ((Number) fila[3]).doubleValue();
            double porcentaje = total > 0 ? (canceladas / total) * 100 : 0.0;
            resultado.add(new EstadisticaEmpleadoDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    canceladas,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    // ===== SERVICIOS =====

    /**
     * {@inheritDoc}
     * valor=totalReservas, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaServicioDTO> serviciosMasSolicitados(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.serviciosMasSolicitados(organizacionId, desde, hasta);

        List<EstadisticaServicioDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            resultado.add(new EstadisticaServicioDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    ((Number) fila[2]).doubleValue(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * {@inheritDoc}
     * valor=importeTotal, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaServicioDTO> importePorServicio(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.importePorServicio(organizacionId, desde, hasta);

        List<EstadisticaServicioDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            resultado.add(new EstadisticaServicioDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    ((Number) fila[2]).doubleValue(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * {@inheritDoc}
     * valor=totalCanceladas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaServicioDTO> cancelacionesPorServicio(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<Object[]> filas = estadisticaDAO.cancelacionesPorServicio(organizacionId, desde, hasta);

        List<EstadisticaServicioDTO> resultado = new ArrayList<>();
        for (Object[] fila : filas) {
            Double total = ((Number) fila[2]).doubleValue();
            Double canceladas = ((Number) fila[3]).doubleValue();
            double porcentaje = total > 0 ? (canceladas / total) * 100 : 0.0;
            resultado.add(new EstadisticaServicioDTO(
                    ((Number) fila[0]).intValue(),
                    (String) fila[1],
                    canceladas,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }
}