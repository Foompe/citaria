package com.citaria.service;

import com.citaria.dto.DisponibilidadDTO;
import com.citaria.dto.PeriodoDisponiblesDTO;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * Tests del cálculo de disponibilidad. Se mockean los DAOs (sin BD) y se
 * comprueban tanto los caminos de salida temprana como la generación de
 * franjas en intervalos de 15 minutos.
 */
@ExtendWith(MockitoExtension.class)
class DisponibilidadServiceImplTest {

    @Mock private OrganizacionHorarioDAO organizacionHorarioDAO;
    @Mock private OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO;
    @Mock private EmpleadoDAO empleadoDAO;
    @Mock private HorarioEmpleadoDAO horarioEmpleadoDAO;
    @Mock private ServicioDAO servicioDAO;
    @Mock private ServicioHabilidadDAO servicioHabilidadDAO;
    @Mock private EmpleadoHabilidadDAO empleadoHabilidadDAO;
    @Mock private ReservaServicioDAO reservaServicioDAO;
    @Mock private ContextoSeguridad contextoSeguridad;

    @InjectMocks private DisponibilidadServiceImpl servicio;

    private Organizacion organizacion;
    private LocalDate fecha;
    private int diaSemana;
    private final List<Integer> servicioIds = List.of(1);

    @BeforeEach
    void setUp() {
        organizacion = org(1);
        // Fecha futura (no hoy) y dentro de los 60 días: evita la lógica de
        // "franja inicio = ahora + 1h" y el límite de antelación.
        fecha = LocalDate.now().plusDays(7);
        diaSemana = fecha.getDayOfWeek().getValue();
    }

    // Salidas tempranas

    @Test
    void fechaMasAllaDe60Dias_lanzaExcepcion() {
        LocalDate lejana = LocalDate.now().plusDays(61);
        assertThrows(IllegalStateException.class,
                () -> servicio.obtenerDisponibilidad(lejana, servicioIds, null));
    }

    @Test
    void diaDeCierre_devuelveFranjasVacias() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFecha(organizacion, fecha))
                .thenReturn(java.util.Optional.of(new OrganizacionHorarioCierre()));

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        assertTrue(resultado.getFranjas().isEmpty());
    }

    @Test
    void sinHorarioDeNegocioEseDia_devuelveFranjasVacias() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFecha(organizacion, fecha))
                .thenReturn(java.util.Optional.empty());
        when(organizacionHorarioDAO.findByOrganizacionAndDiaSemanaAndActivo(organizacion, diaSemana, true))
                .thenReturn(java.util.Optional.empty());

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        assertTrue(resultado.getFranjas().isEmpty());
    }

    @Test
    void duracionTotalCero_devuelveFranjasVacias() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFecha(organizacion, fecha))
                .thenReturn(java.util.Optional.empty());
        when(organizacionHorarioDAO.findByOrganizacionAndDiaSemanaAndActivo(organizacion, diaSemana, true))
                .thenReturn(java.util.Optional.of(horarioNegocio(diaSemana, t(9, 0), t(11, 0))));
        when(servicioDAO.findAllById(servicioIds)).thenReturn(Collections.emptyList());

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        assertTrue(resultado.getFranjas().isEmpty());
    }

    @Test
    void sinEmpleadosValidos_devuelveFranjasVacias() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFecha(organizacion, fecha))
                .thenReturn(java.util.Optional.empty());
        when(organizacionHorarioDAO.findByOrganizacionAndDiaSemanaAndActivo(organizacion, diaSemana, true))
                .thenReturn(java.util.Optional.of(horarioNegocio(diaSemana, t(9, 0), t(11, 0))));
        when(servicioDAO.findAllById(servicioIds)).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(servicioIds)).thenReturn(Collections.emptyList());
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true)).thenReturn(Collections.emptyList());

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        assertTrue(resultado.getFranjas().isEmpty());
    }

    // Cálculo de franjas

    @Test
    void empleadoLibreTodoElDia_generaTodasLasFranjasDisponibles() {
        Empleado empleado = empleado(10);
        stubEscenarioDia(
                horarioNegocio(diaSemana, t(9, 0), t(11, 0)),
                List.of(empleado),
                List.of(horarioEmpleado(empleado, diaSemana, t(9, 0), t(11, 0))),
                Collections.emptyList());

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        // Apertura 09:00, cierre 11:00, duración 30 → franjas cada 15 min desde
        // 09:00 hasta 10:30 (última cuyo fin 11:00 no pasa del cierre) → 7.
        assertEquals(fecha, resultado.getFecha());
        assertEquals(7, resultado.getFranjas().size());
        assertEquals(t(9, 0), resultado.getFranjas().get(0).getHoraInicio());
        assertTrue(resultado.getFranjas().stream()
                .allMatch(f -> f.getEmpleadosDisponibles() == 1));
    }

    @Test
    void reservaQueSolapa_marcaEsasFranjasSinDisponibilidad() {
        Empleado empleado = empleado(10);
        stubEscenarioDia(
                horarioNegocio(diaSemana, t(9, 0), t(11, 0)),
                List.of(empleado),
                List.of(horarioEmpleado(empleado, diaSemana, t(9, 0), t(11, 0))),
                List.of(reservaServicio(empleado, t(9, 0), t(9, 30))));

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        // Reserva 09:00-09:30 solapa las franjas 09:00-09:30 y 09:15-09:45.
        assertEquals(0, resultado.getFranjas().get(0).getEmpleadosDisponibles());
        assertEquals(0, resultado.getFranjas().get(1).getEmpleadosDisponibles());
        assertEquals(1, resultado.getFranjas().get(2).getEmpleadosDisponibles());
        assertEquals(1, resultado.getFranjas().get(resultado.getFranjas().size() - 1)
                .getEmpleadosDisponibles());
    }

    @Test
    void empleadoConHorarioParcial_soloDisponibleDentroDeSuHorario() {
        Empleado empleado = empleado(10);
        stubEscenarioDia(
                horarioNegocio(diaSemana, t(9, 0), t(11, 0)),
                List.of(empleado),
                List.of(horarioEmpleado(empleado, diaSemana, t(10, 0), t(11, 0))),
                Collections.emptyList());

        DisponibilidadDTO resultado = servicio.obtenerDisponibilidad(fecha, servicioIds, null);

        // Empleado trabaja 10:00-11:00 → franja 09:00 sin disponibilidad,
        // franja 10:00 (índice 4) disponible.
        assertEquals(t(9, 0), resultado.getFranjas().get(0).getHoraInicio());
        assertEquals(0, resultado.getFranjas().get(0).getEmpleadosDisponibles());
        assertEquals(t(10, 0), resultado.getFranjas().get(4).getHoraInicio());
        assertEquals(1, resultado.getFranjas().get(4).getEmpleadosDisponibles());
    }

    // Periodo

    @Test
    void periodoConCierre_excluyeElDiaCerrado() {
        LocalDate dia1 = LocalDate.now().plusDays(7);
        LocalDate dia2 = LocalDate.now().plusDays(8);
        int sem1 = dia1.getDayOfWeek().getValue();
        int sem2 = dia2.getDayOfWeek().getValue();
        Empleado empleado = empleado(10);

        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(servicioDAO.findAllById(servicioIds)).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(servicioIds)).thenReturn(Collections.emptyList());
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true)).thenReturn(List.of(empleado));
        when(organizacionHorarioDAO.findByOrganizacionAndActivo(organizacion, true)).thenReturn(List.of(
                horarioNegocio(sem1, t(9, 0), t(18, 0)),
                horarioNegocio(sem2, t(9, 0), t(18, 0))));
        OrganizacionHorarioCierre cierre = new OrganizacionHorarioCierre();
        cierre.setFecha(dia1);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFechaBetween(organizacion, dia1, dia2))
                .thenReturn(List.of(cierre));
        when(horarioEmpleadoDAO.findByEmpleadoIn(List.of(empleado))).thenReturn(List.of(
                horarioEmpleado(empleado, sem1, t(9, 0), t(18, 0)),
                horarioEmpleado(empleado, sem2, t(9, 0), t(18, 0))));
        when(reservaServicioDAO.findActivosByEmpleadosAndPeriodo(List.of(empleado), dia1, dia2))
                .thenReturn(Collections.emptyList());

        PeriodoDisponiblesDTO resultado = servicio.obtenerDiasDisponiblesPeriodo(dia1, dia2, servicioIds, null);

        assertEquals(List.of(dia2), resultado.getFechasDisponibles());
    }

    // Primera franja del día (borde de medianoche)

    @Test
    void cercaDeMedianoche_noHabilitaTodoElHorario() {
        // Regresión: a las 23:30 el margen de +1h da la vuelta del reloj (00:30).
        // Sin protección devolvía la apertura y habilitaba todo el día; debe
        // devolver 23:59 para que no quede ninguna franja reservable hoy.
        assertEquals(t(23, 59), servicio.primeraFranjaDesdeAhora(t(23, 30), t(9, 0)));
        assertEquals(t(23, 59), servicio.primeraFranjaDesdeAhora(t(23, 55), t(9, 0)));
    }

    @Test
    void duranteElDia_dejaMargenDeUnaHoraYRedondea() {
        // Hora en punto: margen +1h exacto, sin redondeo.
        assertEquals(t(11, 0), servicio.primeraFranjaDesdeAhora(t(10, 0), t(9, 0)));
        // Minuto no múltiplo de 15: redondea hacia arriba al intervalo.
        assertEquals(t(11, 15), servicio.primeraFranjaDesdeAhora(t(10, 7), t(9, 0)));
    }

    @Test
    void antesDeAbrir_devuelveLaApertura() {
        // El margen cae antes de la apertura → arranca en la apertura.
        assertEquals(t(9, 0), servicio.primeraFranjaDesdeAhora(t(8, 0), t(9, 0)));
    }

    // Helpers

    /** Stubs comunes del flujo completo de un día (cierre vacío, horario, etc.). */
    private void stubEscenarioDia(OrganizacionHorario horario,
                                  List<Empleado> empleados,
                                  List<HorarioEmpleado> horariosEmpleado,
                                  List<ReservaServicio> reservas) {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(organizacionHorarioCierreDAO.findByOrganizacionAndFecha(organizacion, fecha))
                .thenReturn(java.util.Optional.empty());
        when(organizacionHorarioDAO.findByOrganizacionAndDiaSemanaAndActivo(organizacion, diaSemana, true))
                .thenReturn(java.util.Optional.of(horario));
        when(servicioDAO.findAllById(servicioIds)).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(servicioIds)).thenReturn(Collections.emptyList());
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true)).thenReturn(empleados);
        when(horarioEmpleadoDAO.findByEmpleadoIn(empleados)).thenReturn(horariosEmpleado);
        when(reservaServicioDAO.findActivosByEmpleadosAndPeriodo(empleados, fecha, fecha)).thenReturn(reservas);
    }

    private static LocalTime t(int hora, int minuto) {
        return LocalTime.of(hora, minuto);
    }

    private Organizacion org(int id) {
        Organizacion o = new Organizacion();
        o.setId(id);
        return o;
    }

    private OrganizacionHorario horarioNegocio(int dia, LocalTime apertura, LocalTime cierre) {
        OrganizacionHorario h = new OrganizacionHorario();
        h.setDiaSemana(dia);
        h.setHoraApertura(apertura);
        h.setHoraCierre(cierre);
        h.setActivo(true);
        return h;
    }

    private Empleado empleado(int id) {
        Empleado e = new Empleado();
        e.setId(id);
        e.setOrganizacion(organizacion);
        e.setActivo(true);
        return e;
    }

    private HorarioEmpleado horarioEmpleado(Empleado empleado, int dia, LocalTime inicio, LocalTime fin) {
        HorarioEmpleado h = new HorarioEmpleado();
        h.setEmpleado(empleado);
        h.setDiaSemana(dia);
        h.setHoraInicio(inicio);
        h.setHoraFin(fin);
        h.setActivo(true);
        return h;
    }

    private Servicio servicio(int id, int duracionMinutos) {
        Servicio s = new Servicio();
        s.setId(id);
        s.setOrganizacion(organizacion);
        s.setActivo(true);
        s.setDuracionMinutos(duracionMinutos);
        return s;
    }

    private ReservaServicio reservaServicio(Empleado empleado, LocalTime inicio, LocalTime fin) {
        ReservaServicio rs = new ReservaServicio();
        rs.setEmpleado(empleado);
        rs.setHoraInicio(inicio);
        rs.setHoraFin(fin);
        Reserva r = new Reserva();
        r.setFecha(fecha);
        rs.setReserva(r);
        return rs;
    }
}
