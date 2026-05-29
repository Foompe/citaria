package com.citaria.service;

import com.citaria.dto.DisponibilidadDTO;
import com.citaria.dto.FranjaHorariaDTO;
import com.citaria.dto.PeriodoDisponiblesDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

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
        if (fecha.isAfter(LocalDate.now().plusDays(60))) {
            throw new IllegalStateException("No se pueden consultar fechas con más de 60 días de antelación");
        }
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
        if (empleadosValidos.isEmpty()) {
            return new DisponibilidadDTO(fecha, new ArrayList<>());
        }

        // 5. Pre-cargar horarios y reservas en batch (elimina N+1)
        Map<Integer, List<HorarioEmpleado>> horariosPorEmpleado = new HashMap<>();
        for (HorarioEmpleado horario : horarioEmpleadoDAO.findByEmpleadoIn(empleadosValidos)) {
            horariosPorEmpleado
                    .computeIfAbsent(horario.getEmpleado().getId(), k -> new ArrayList<>())
                    .add(horario);
        }

        Map<Integer, List<ReservaServicio>> reservasPorEmpleado = new HashMap<>();
        for (ReservaServicio rs : reservaServicioDAO
                .findActivosByEmpleadosAndPeriodo(empleadosValidos, fecha, fecha)) {
            reservasPorEmpleado
                    .computeIfAbsent(rs.getEmpleado().getId(), k -> new ArrayList<>())
                    .add(rs);
        }

        // 6. Calcular franjas en intervalos de 15 minutos
        List<FranjaHorariaDTO> franjas = new ArrayList<>();
        LocalTime franjaInicio = calcularFranjaInicio(fecha, apertura);

        while (!franjaInicio.isAfter(horaCierre.minusMinutes(duracionTotalMinutos))) {
            LocalTime franjaFin = franjaInicio.plusMinutes(duracionTotalMinutos);
            int disponibles = 0;
            for (Empleado empleado : empleadosValidos) {
                if (empleadoLibreEnFranja(empleado, diaSemana, franjaInicio, franjaFin,
                        horariosPorEmpleado, reservasPorEmpleado)) {
                    disponibles++;
                }
            }
            franjas.add(new FranjaHorariaDTO(
                    franjaInicio, franjaFin,
                    disponibles > 0,
                    disponibles));
            franjaInicio = franjaInicio.plusMinutes(INTERVALO_MINUTOS);
        }

        return new DisponibilidadDTO(fecha, franjas);
    }

    @Override
    @Transactional(readOnly = true)
    public PeriodoDisponiblesDTO obtenerDiasDisponiblesPeriodo(LocalDate fechaInicio,
                                                               LocalDate fechaFin,
                                                               List<Integer> servicioIds,
                                                               Integer empleadoId) {
        if (fechaFin.isAfter(LocalDate.now().plusDays(60))) {
            throw new IllegalStateException("No se pueden consultar fechas con más de 60 días de antelación");
        }
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();

        int duracionTotalMinutos = calcularDuracionTotal(servicioIds, organizacion);
        if (duracionTotalMinutos == 0) {
            return new PeriodoDisponiblesDTO(new ArrayList<>());
        }

        List<Integer> skillsRequeridas = servicioSkillDAO.obtenerSkillIdsRequeridas(servicioIds);
        List<Empleado> empleadosValidos = obtenerEmpleadosValidos(organizacion, skillsRequeridas, empleadoId);
        if (empleadosValidos.isEmpty()) {
            return new PeriodoDisponiblesDTO(new ArrayList<>());
        }

        // Horarios del negocio por día de semana (1=lunes…7=domingo)
        Map<Integer, OrganizacionHorario> horarioNegocioPorDia = new HashMap<>();
        for (OrganizacionHorario horario : organizacionHorarioDAO.findByOrganizacionAndActivo(organizacion, true)) {
            horarioNegocioPorDia.put(horario.getDiaSemana(), horario);
        }

        // Cierres puntuales del período
        Set<LocalDate> fechasCierre = new HashSet<>();
        for (OrganizacionHorarioCierre cierre : organizacionHorarioCierreDAO
                .findByOrganizacionAndFechaBetween(organizacion, fechaInicio, fechaFin)) {
            fechasCierre.add(cierre.getFecha());
        }

        // Horarios de todos los empleados válidos (Map<empleadoId, List<HorarioEmpleado>>)
        Map<Integer, List<HorarioEmpleado>> horariosPorEmpleado = new HashMap<>();
        for (HorarioEmpleado horario : horarioEmpleadoDAO.findByEmpleadoIn(empleadosValidos)) {
            horariosPorEmpleado
                    .computeIfAbsent(horario.getEmpleado().getId(), k -> new ArrayList<>())
                    .add(horario);
        }

        // Reservas activas del período (Map<fecha, Map<empleadoId, List<ReservaServicio>>>)
        Map<LocalDate, Map<Integer, List<ReservaServicio>>> reservasPorFechaYEmpleado = new HashMap<>();
        for (ReservaServicio rs : reservaServicioDAO
                .findActivosByEmpleadosAndPeriodo(empleadosValidos, fechaInicio, fechaFin)) {
            LocalDate fechaRs = rs.getReserva().getFecha();
            Integer empId = rs.getEmpleado().getId();
            reservasPorFechaYEmpleado
                    .computeIfAbsent(fechaRs, k -> new HashMap<>())
                    .computeIfAbsent(empId, k -> new ArrayList<>())
                    .add(rs);
        }

        // Iterar cada día del período y comprobar si hay al menos una franja disponible
        List<LocalDate> fechasDisponibles = new ArrayList<>();
        LocalDate fecha = fechaInicio;
        while (!fecha.isAfter(fechaFin)) {
            if (hayDisponibilidadEnDia(fecha, duracionTotalMinutos, horarioNegocioPorDia,
                    fechasCierre, empleadosValidos, horariosPorEmpleado, reservasPorFechaYEmpleado)) {
                fechasDisponibles.add(fecha);
            }
            fecha = fecha.plusDays(1);
        }

        return new PeriodoDisponiblesDTO(fechasDisponibles);
    }

    private boolean hayDisponibilidadEnDia(LocalDate fecha,
                                            int duracionTotalMinutos,
                                            Map<Integer, OrganizacionHorario> horarioNegocioPorDia,
                                            Set<LocalDate> fechasCierre,
                                            List<Empleado> empleadosValidos,
                                            Map<Integer, List<HorarioEmpleado>> horariosPorEmpleado,
                                            Map<LocalDate, Map<Integer, List<ReservaServicio>>> reservasPorFechaYEmpleado) {
        if (fechasCierre.contains(fecha)) {
            return false;
        }

        int diaSemana = fecha.getDayOfWeek().getValue();
        OrganizacionHorario horarioNegocio = horarioNegocioPorDia.get(diaSemana);
        if (horarioNegocio == null) {
            return false;
        }

        Map<Integer, List<ReservaServicio>> reservasDelDia =
                reservasPorFechaYEmpleado.getOrDefault(fecha, new HashMap<>());

        LocalTime franjaInicio = calcularFranjaInicio(fecha, horarioNegocio.getHoraApertura());
        LocalTime horaCierre = horarioNegocio.getHoraCierre();

        while (!franjaInicio.isAfter(horaCierre.minusMinutes(duracionTotalMinutos))) {
            LocalTime franjaFin = franjaInicio.plusMinutes(duracionTotalMinutos);
            for (Empleado empleado : empleadosValidos) {
                if (empleadoLibreEnFranja(empleado, diaSemana, franjaInicio, franjaFin,
                        horariosPorEmpleado, reservasDelDia)) {
                    return true;
                }
            }
            franjaInicio = franjaInicio.plusMinutes(INTERVALO_MINUTOS);
        }
        return false;
    }

    private boolean empleadoLibreEnFranja(Empleado empleado,
                                           int diaSemana,
                                           LocalTime horaInicio,
                                           LocalTime horaFin,
                                           Map<Integer, List<HorarioEmpleado>> horariosPorEmpleado,
                                           Map<Integer, List<ReservaServicio>> reservasDelDia) {
        List<HorarioEmpleado> horarios = horariosPorEmpleado.getOrDefault(empleado.getId(), new ArrayList<>());
        boolean trabajaEnFranja = false;
        for (HorarioEmpleado horario : horarios) {
            if (horario.getDiaSemana().equals(diaSemana)
                    && Boolean.TRUE.equals(horario.getActivo())
                    && !horaInicio.isBefore(horario.getHoraInicio())
                    && !horaFin.isAfter(horario.getHoraFin())) {
                trabajaEnFranja = true;
                break;
            }
        }
        if (!trabajaEnFranja) {
            return false;
        }

        List<ReservaServicio> reservasEmpleado = reservasDelDia.getOrDefault(empleado.getId(), new ArrayList<>());
        for (ReservaServicio rs : reservasEmpleado) {
            if (rs.getHoraInicio().isBefore(horaFin) && rs.getHoraFin().isAfter(horaInicio)) {
                return false;
            }
        }
        return true;
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

    private LocalTime calcularFranjaInicio(LocalDate fecha, LocalTime apertura) {
        if (!fecha.equals(LocalDate.now())) {
            return apertura;
        }
        LocalTime ahora = LocalTime.now();
        LocalTime limite = ahora.plusHours(1);
        // Si plusHours(1) da la vuelta pasada medianoche, no quedan franjas hoy
        if (!limite.isAfter(ahora)) {
            return LocalTime.of(23, 59);
        }
        int resto = limite.getMinute() % INTERVALO_MINUTOS;
        if (resto != 0) {
            LocalTime redondeado = limite.plusMinutes(INTERVALO_MINUTOS - resto);
            // Solo aplicar redondeo si no da la vuelta pasada medianoche
            if (redondeado.isAfter(limite)) {
                limite = redondeado;
            }
        }
        limite = limite.withSecond(0).withNano(0);
        return limite.isAfter(apertura) ? limite : apertura;
    }
}
