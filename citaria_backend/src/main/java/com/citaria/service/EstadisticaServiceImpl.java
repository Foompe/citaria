package com.citaria.service;

import com.citaria.dto.EstadisticaItemDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.ResumenEstadisticaDTO;
import com.citaria.repository.EstadisticaDAO;
import com.citaria.repository.projection.FilaImporteEstadistica;
import com.citaria.repository.projection.FilaItemEstadistica;
import com.citaria.repository.projection.FilaMesEstadistica;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Implementación del servicio de estadísticas.
 */
@Service
public class EstadisticaServiceImpl implements EstadisticaService {

    private final EstadisticaDAO estadisticaDAO;
    private final ContextoSeguridad contextoSeguridad;

    @Autowired
    public EstadisticaServiceImpl(EstadisticaDAO estadisticaDAO,
                                  ContextoSeguridad contextoSeguridad) {
        this.estadisticaDAO = estadisticaDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    @Override
    @Transactional(readOnly = true)
    public ResumenEstadisticaDTO obtenerResumen() {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        LocalDate hoy = LocalDate.now();
        int anio = hoy.getYear();
        int mes = hoy.getMonthValue();
        LocalDate inicioMes = hoy.withDayOfMonth(1);
        LocalDate finMes = inicioMes.withDayOfMonth(inicioMes.lengthOfMonth());

        Long reservasHoy = estadisticaDAO.contarReservasPorFecha(organizacionId, hoy);
        Long reservasMes = estadisticaDAO.contarReservasPorMes(organizacionId, anio, mes);

        BigDecimal facturacionHoy = estadisticaDAO.facturacionPorFecha(organizacionId, hoy);
        BigDecimal facturacionMes = estadisticaDAO.facturacionPorMes(organizacionId, anio, mes);

        if (facturacionHoy == null) {
            facturacionHoy = BigDecimal.ZERO;
        }
        if (facturacionMes == null) {
            facturacionMes = BigDecimal.ZERO;
        }

        Long clientesNuevosMes = estadisticaDAO.contarClientesNuevosMes(organizacionId, inicioMes, finMes);
        String servicioMasSolicitado = estadisticaDAO.servicioMasSolicitadoMes(organizacionId, anio, mes);

        return new ResumenEstadisticaDTO(
                reservasHoy,
                reservasMes,
                facturacionHoy,
                facturacionMes,
                clientesNuevosMes,
                servicioMasSolicitado
        );
    }

    // CLIENTES

    /**
     * Combina los resultados de dos queries (nuevos y recurrentes) indexando
     * por período para garantizar que todos los meses del rango aparecen
     * en la respuesta aunque no haya clientes nuevos o recurrentes ese mes.
     * valor1=nuevos, valor2=recurrentes
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaMesDTO> clientesNuevosVsRecurrentes(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();

        List<FilaMesEstadistica> nuevos = estadisticaDAO.contarClientesNuevosPorMes(organizacionId, desde, hasta);
        List<FilaMesEstadistica> recurrentes = estadisticaDAO.contarClientesRecurrentesPorMes(organizacionId, desde, hasta);

        Map<String, Double> mapaRecurrentes = new HashMap<>();
        for (FilaMesEstadistica fila : recurrentes) {
            mapaRecurrentes.put(fila.getPeriodo(), fila.getValor1());
        }

        List<EstadisticaMesDTO> resultado = new ArrayList<>();
        for (FilaMesEstadistica fila : nuevos) {
            Double cantidadRecurrentes = mapaRecurrentes.getOrDefault(fila.getPeriodo(), 0.0);
            resultado.add(new EstadisticaMesDTO(fila.getPeriodo(), fila.getValor1(), cantidadRecurrentes));
        }
        return resultado;
    }

    /**
     * valor1=totalClientes, valor2=porcentajeRetencion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaMesDTO> fidelizacionClientes(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaMesEstadistica> filas = estadisticaDAO.calcularFidelizacionPorMes(organizacionId, desde, hasta);

        List<EstadisticaMesDTO> resultado = new ArrayList<>();
        for (FilaMesEstadistica fila : filas) {
            Double totalClientes = fila.getValor1();
            Double repiten = fila.getValor2();
            double porcentaje;
            if (totalClientes > 0) {
                porcentaje = (repiten / totalClientes) * 100;
            } else {
                porcentaje = 0.0;
            }
            resultado.add(new EstadisticaMesDTO(
                    fila.getPeriodo(),
                    totalClientes,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    // EMPLEADOS

    /**
     * valor=totalReservas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> reservasPorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaItemEstadistica> filas = estadisticaDAO.reservasPorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaItemEstadistica fila : filas) {
            Double total = fila.getTotal();
            Double canceladas = fila.getCanceladas();
            double porcentajeCancelacion;
            if (total > 0) {
                porcentajeCancelacion = (canceladas / total) * 100;
            } else {
                porcentajeCancelacion = 0.0;
            }
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    total,
                    Math.round(porcentajeCancelacion * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    /**
     * valor=importeTotal, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> importePorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaImporteEstadistica> filas = estadisticaDAO.importePorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaImporteEstadistica fila : filas) {
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    fila.getImporte(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * valor=totalCanceladas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> cancelacionesPorEmpleado(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaItemEstadistica> filas = estadisticaDAO.cancelacionesPorEmpleado(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaItemEstadistica fila : filas) {
            Double total = fila.getTotal();
            Double canceladas = fila.getCanceladas();
            double porcentaje;
            if (total > 0) {
                porcentaje = (canceladas / total) * 100;
            } else {
                porcentaje = 0.0;
            }
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    canceladas,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }

    // SERVICIOS

    /**
     * valor=totalReservas, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> serviciosMasSolicitados(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaItemEstadistica> filas = estadisticaDAO.serviciosMasSolicitados(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaItemEstadistica fila : filas) {
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    fila.getTotal(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * valor=importeTotal, porcentaje=null
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> importePorServicio(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaImporteEstadistica> filas = estadisticaDAO.importePorServicio(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaImporteEstadistica fila : filas) {
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    fila.getImporte(),
                    null
            ));
        }
        return resultado;
    }

    /**
     * valor=totalCanceladas, porcentaje=tasaCancelacion
     */
    @Override
    @Transactional(readOnly = true)
    public List<EstadisticaItemDTO> cancelacionesPorServicio(LocalDate desde, LocalDate hasta) {
        Integer organizacionId = contextoSeguridad.obtenerOrganizacionIdActual();
        List<FilaItemEstadistica> filas = estadisticaDAO.cancelacionesPorServicio(organizacionId, desde, hasta);

        List<EstadisticaItemDTO> resultado = new ArrayList<>();
        for (FilaItemEstadistica fila : filas) {
            Double total = fila.getTotal();
            Double canceladas = fila.getCanceladas();
            double porcentaje;
            if (total > 0) {
                porcentaje = (canceladas / total) * 100;
            } else {
                porcentaje = 0.0;
            }
            resultado.add(new EstadisticaItemDTO(
                    fila.getId(),
                    fila.getNombre(),
                    canceladas,
                    Math.round(porcentaje * 100.0) / 100.0
            ));
        }
        return resultado;
    }
}
