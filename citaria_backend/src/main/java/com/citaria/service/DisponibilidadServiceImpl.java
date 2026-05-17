package com.citaria.service;

import com.citaria.dto.DiasDisponiblesDTO;
import com.citaria.dto.DisponibilidadDTO;
import com.citaria.dto.FranjaHorariaDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de disponibilidad.
 *
 * Algoritmo por franja (intervalos de 15 minutos):
 * 1. Verificar que la fecha no es un cierre puntual.
 * 2. Obtener el horario de apertura/cierre del negocio para ese día.
 * 3. Calcular la duración total de los servicios seleccionados.
 * 4. Obtener los empleados que tienen todas las skills requeridas.
 * 5. Para cada franja desde apertura hasta (cierre - duración):
 *    - Para cada empleado válido, verificar que trabaja ese día y que no tiene solapamiento.
 *    - Si al menos uno pasa los checks, la franja es disponible.
 */
@Service
public class DisponibilidadServiceImpl implements DisponibilidadService {

    private static final Logger logger = LoggerFactory.getLogger(DisponibilidadServiceImpl.class);
    private static final int INTERVALO_MINUTOS = 15;

    private final OrganizacionHorarioDAO organizacionHorarioDAO;
    private final OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO;
    private final EmpleadoDAO empleadoDAO;
    private final HorarioEmpleadoDAO horarioEmpleadoDAO;
    private final ServicioDAO servicioDAO;
    private final ServicioSkillDAO servicioSkillDAO;
    private final EmpleadoSkillDAO empleadoSkillDAO;
    private final ReservaServicioDAO reservaServicioDAO;
    private final ContextoSeguridad contextoSeguridad;

    @Autowired
    public DisponibilidadServiceImpl(OrganizacionHorarioDAO organizacionHorarioDAO,
                                     OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO,
                                     EmpleadoDAO empleadoDAO,
                                     HorarioEmpleadoDAO horarioEmpleadoDAO,
                                     ServicioDAO servicioDAO,
                                     ServicioSkillDAO servicioSkillDAO,
                                     EmpleadoSkillDAO empleadoSkillDAO,
                                     ReservaServicioDAO reservaServicioDAO,
                                     ContextoSeguridad contextoSeguridad) {
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.organizacionHorarioCierreDAO = organizacionHorarioCierreDAO;
        this.empleadoDAO = empleadoDAO;
        this.horarioEmpleadoDAO = horarioEmpleadoDAO;
        this.servicioDAO = servicioDAO;
        this.servicioSkillDAO = servicioSkillDAO;
        this.empleadoSkillDAO = empleadoSkillDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    @Override
    @Transactional(readOnly = true)
    public DisponibilidadDTO obtenerDisponibilidad(LocalDate fecha,
                                                   List<Integer> servicioIds,
                                                   Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();

        // 1. Verificar que no es un día de cierre puntual
        Optional<OrganizacionHorarioCierre> cierre = organizacionHorarioCierreDAO
                .findByOrganizacionAndFecha(organizacion, fecha);
        if (cierre.isPresent()) {
            return new DisponibilidadDTO(fecha, new ArrayList<>());
        }

        // 2. Obtener horario del negocio para ese día de la semana (1=lunes, 7=domingo)
        int diaSemana = fecha.getDayOfWeek().getValue();
        Optional<OrganizacionHorario> horarioNegocio = organizacionHorarioDAO
                .findByOrganizacionAndDiaSemanaAndActivo(organizacion, diaSemana, true);
        if (horarioNegocio.isEmpty()) {
            return new DisponibilidadDTO(fecha, new ArrayList<>());
        }

        LocalTime apertura = horarioNegocio.get().getHoraApertura();
        LocalTime horaCierre = horarioNegocio.get().getHoraCierre();

        // 3. Calcular duración total de los servicios
        int duracionTotalMinutos = calcularDuracionTotal(servicioIds, organizacion);
        if (duracionTotalMinutos == 0) {
            return new DisponibilidadDTO(fecha, new ArrayList<>());
        }

        // 4. Obtener empleados válidos (con todas las skills requeridas)
        List<Integer> skillsRequeridas = servicioSkillDAO.obtenerSkillIdsRequeridas(servicioIds);
        List<Empleado> empleadosValidos = obtenerEmpleadosValidos(
                organizacion, skillsRequeridas, empleadoId);

        // 5. Calcular franjas en intervalos de 15 minutos
        List<FranjaHorariaDTO> franjas = new ArrayList<>();
        LocalTime franjaInicio = apertura;

        while (!franjaInicio.plusMinutes(duracionTotalMinutos).isAfter(horaCierre)) {
            LocalTime franjaFin = franjaInicio.plusMinutes(duracionTotalMinutos);
            int empleadosDisponibles = contarEmpleadosDisponibles(
                    empleadosValidos, fecha, franjaInicio, franjaFin, diaSemana);
            franjas.add(new FranjaHorariaDTO(
                    franjaInicio, franjaFin,
                    empleadosDisponibles > 0,
                    empleadosDisponibles));
            franjaInicio = franjaInicio.plusMinutes(INTERVALO_MINUTOS);
        }

        return new DisponibilidadDTO(fecha, franjas);
    }

    @Override
    @Transactional(readOnly = true)
    public DiasDisponiblesDTO obtenerDiasDisponibles(Integer anio,
                                                     Integer mes,
                                                     List<Integer> servicioIds,
                                                     Integer empleadoId) {
        YearMonth mesConsultado = YearMonth.of(anio, mes);
        YearMonth mesActual = YearMonth.now();

        if (mesConsultado.isBefore(mesActual)) {
            return new DiasDisponiblesDTO(new ArrayList<>());
        }

        LocalDate hoy = LocalDate.now();
        int primerDia = 1;
        if (mesConsultado.equals(mesActual)) {
            primerDia = hoy.getDayOfMonth();
        }

        List<Integer> diasDisponibles = new ArrayList<>();
        for (int dia = primerDia; dia <= mesConsultado.lengthOfMonth(); dia++) {
            LocalDate fecha = mesConsultado.atDay(dia);
            try {
                DisponibilidadDTO disponibilidad = obtenerDisponibilidad(fecha, servicioIds, empleadoId);
                boolean tieneDisponibilidad = disponibilidad.getFranjas().stream()
                        .anyMatch(FranjaHorariaDTO::isDisponible);
                if (tieneDisponibilidad) {
                    diasDisponibles.add(dia);
                }
            } catch (Exception ex) {
                logger.warn("No se pudo calcular la disponibilidad para la fecha {}", fecha, ex);
            }
        }

        return new DiasDisponiblesDTO(diasDisponibles);
    }

    // MÉTODOS AUXILIARES

    /**
     * Suma la duración en minutos de todos los servicios seleccionados.
     */
    private int calcularDuracionTotal(List<Integer> servicioIds, Organizacion organizacion) {
        List<Servicio> servicios = servicioDAO.findAllById(servicioIds);
        int total = 0;
        for (Servicio servicio : servicios) {
            if (!servicio.getOrganizacion().getId().equals(organizacion.getId())) {
                throw new RecursoNoEncontradoException("Servicio con id " + servicio.getId() + " no encontrado");
            }
            if (!Boolean.TRUE.equals(servicio.getActivo())) {
                throw new RecursoNoEncontradoException("Servicio con id " + servicio.getId() + " no encontrado");
            }
            total += servicio.getDuracionMinutos();
        }
        return total;
    }

    /**
     * Devuelve los empleados/empleado activos de la organización que tienen todas las skills requeridas.
     */
    private List<Empleado> obtenerEmpleadosValidos(Organizacion organizacion,
                                                   List<Integer> skillsRequeridas,
                                                   Integer empleadoId) {
        List<Empleado> candidatos;
        if (empleadoId != null) {
            Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
            if (empleadoOptional.isEmpty()) {
                throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
            }
            Empleado empleado = empleadoOptional.get();
            if (!empleado.getOrganizacion().getId().equals(organizacion.getId())) {
                throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
            }
            candidatos = new ArrayList<>();
            candidatos.add(empleado);
        } else {
            candidatos = empleadoDAO.findByOrganizacionAndActivo(organizacion, true);
        }

        if (skillsRequeridas.isEmpty()) {
            return candidatos;
        }

        List<Empleado> validos = new ArrayList<>();
        for (Empleado empleado : candidatos) {
            long skillsQueElEmpleadoTiene = empleadoSkillDAO
                    .contarSkillsQueCoinciden(empleado, skillsRequeridas);
            if (skillsQueElEmpleadoTiene >= skillsRequeridas.size()) {
                validos.add(empleado);
            }
        }
        return validos;
    }

    /**
     * Cuenta cuántos empleados de la lista están disponibles para la franja indicada.
     * Un empleado está disponible si trabaja ese día en esa franja y no tiene otra cita en esa franja
     */
    private int contarEmpleadosDisponibles(List<Empleado> empleados,
                                           LocalDate fecha,
                                           LocalTime horaInicio,
                                           LocalTime horaFin,
                                           int diaSemana) {
        int disponibles = 0;
        for (Empleado empleado : empleados) {
            if (empleadoDisponibleEnFranja(empleado, fecha, horaInicio, horaFin, diaSemana)) {
                disponibles++;
            }
        }
        return disponibles;
    }

    /**
     * Verifica que el empleado trabaja ese día en esa franja horaria
     * y que no tiene ninguna reserva.
     */
    private boolean empleadoDisponibleEnFranja(Empleado empleado,
                                               LocalDate fecha,
                                               LocalTime horaInicio,
                                               LocalTime horaFin,
                                               int diaSemana) {
        // Verificar horario del empleado
        Optional<HorarioEmpleado> horario = horarioEmpleadoDAO
                .findByEmpleadoAndDiaSemanaAndActivo(empleado, diaSemana, true);
        if (horario.isEmpty()) {
            return false;
        }
        if (horaInicio.isBefore(horario.get().getHoraInicio())
                || horaFin.isAfter(horario.get().getHoraFin())) {
            return false;
        }

        // Verificar solapamiento con reservas existentes
        long solapamientos = reservaServicioDAO.contarSolapamientos(
                empleado.getId(), fecha, horaInicio, horaFin);
        return solapamientos == 0;
    }
}
