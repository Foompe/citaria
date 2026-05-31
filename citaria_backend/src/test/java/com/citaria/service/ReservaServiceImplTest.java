package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.exception.RecursoNoEncontradoException;
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
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests de la lógica de negocio de reservas. Se mockean los DAOs (sin BD) y se
 * cubren solo las partes con reglas reales: validaciones y flujo de {@code crear}
 * (incluida la asignación automática de empleado), la máquina de estados de
 * {@code actualizarEstado} y las restricciones de {@code cancelar} para el cliente.
 * El CRUD trivial y los conversores quedan fuera a propósito.
 */
@ExtendWith(MockitoExtension.class)
class ReservaServiceImplTest {

    @Mock private ReservaDAO reservaDAO;
    @Mock private ReservaServicioDAO reservaServicioDAO;
    @Mock private ClienteDAO clienteDAO;
    @Mock private ServicioDAO servicioDAO;
    @Mock private EmpleadoDAO empleadoDAO;
    @Mock private EmpleadoHabilidadDAO empleadoHabilidadDAO;
    @Mock private ServicioHabilidadDAO servicioHabilidadDAO;
    @Mock private HorarioEmpleadoDAO horarioEmpleadoDAO;
    @Mock private ContextoSeguridad contextoSeguridad;

    @InjectMocks private ReservaServiceImpl servicio;

    private Organizacion organizacion;
    private Cliente cliente;
    private LocalDate fechaFutura;
    private final Integer clienteId = 100;

    @BeforeEach
    void setUp() {
        organizacion = org(1);
        cliente = cliente(clienteId);
        fechaFutura = LocalDate.now().plusDays(7);
    }

    // ── crear: validaciones de entrada (IllegalArgumentException) ────────────

    @Test
    void crear_sinServicios_lanzaIllegalArgument() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));

        ReservaDTO dto = dto(null, t(10, 0), fechaFutura, null);

        assertThrows(IllegalArgumentException.class, () -> servicio.crear(clienteId, dto));
    }

    @Test
    void crear_sinHoraInicio_lanzaIllegalArgument() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));

        ReservaDTO dto = dto(List.of(1), null, fechaFutura, null);

        assertThrows(IllegalArgumentException.class, () -> servicio.crear(clienteId, dto));
    }

    @Test
    void crear_fechaPasada_lanzaIllegalArgument() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));

        ReservaDTO dto = dto(List.of(1), t(10, 0), LocalDate.now().minusDays(1), null);

        assertThrows(IllegalArgumentException.class, () -> servicio.crear(clienteId, dto));
    }

    // ── crear: reglas de negocio ─────────────────────────────────────────────

    @Test
    void crear_conCincoReservasActivas_lanzaIllegalState() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.nCopies(5, new Reserva()));

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, null);

        assertThrows(IllegalStateException.class, () -> servicio.crear(clienteId, dto));
    }

    @Test
    void crear_empleadoManualConSolape_lanzaIllegalState() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.emptyList());
        when(servicioDAO.findAllById(any())).thenReturn(List.of(servicio(1, 30)));
        when(empleadoDAO.findById(10)).thenReturn(Optional.of(empleado(10)));
        when(reservaServicioDAO.contarSolapamientos(anyInt(), any(), any(), any())).thenReturn(1L);

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, 10);

        assertThrows(IllegalStateException.class, () -> servicio.crear(clienteId, dto));
    }

    @Test
    void crear_empleadoManualSinSolape_guardaCabeceraYLineas() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.emptyList());
        when(servicioDAO.findAllById(any())).thenReturn(List.of(servicio(1, 30)));
        when(empleadoDAO.findById(10)).thenReturn(Optional.of(empleado(10)));
        when(reservaServicioDAO.contarSolapamientos(anyInt(), any(), any(), any())).thenReturn(0L);
        when(reservaDAO.save(any(Reserva.class))).thenAnswer(inv -> inv.getArgument(0));

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, 10);
        ReservaDTO resultado = servicio.crear(clienteId, dto);

        assertEquals(EstadoReserva.pendiente, resultado.getEstado());
        verify(reservaDAO).save(any(Reserva.class));
        verify(reservaServicioDAO).save(any(ReservaServicio.class));
    }

    // ── crear: asignación automática de empleado ─────────────────────────────

    @Test
    void crear_sinEmpleado_asignaElDeMenorCarga() {
        int diaSemana = fechaFutura.getDayOfWeek().getValue();
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.emptyList());
        when(servicioDAO.findAllById(any())).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(any())).thenReturn(Collections.emptyList());
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true))
                .thenReturn(List.of(empleado(1), empleado(2)));
        when(horarioEmpleadoDAO.findByEmpleadoAndDiaSemanaAndActivo(any(), eq(diaSemana), eq(true)))
                .thenReturn(Optional.of(horario(t(9, 0), t(18, 0))));
        when(reservaServicioDAO.contarSolapamientos(anyInt(), any(), any(), any())).thenReturn(0L);
        when(reservaServicioDAO.contarReservasPorEmpleadoYFecha(eq(1), any())).thenReturn(5L);
        when(reservaServicioDAO.contarReservasPorEmpleadoYFecha(eq(2), any())).thenReturn(2L);
        when(reservaDAO.save(any(Reserva.class))).thenAnswer(inv -> inv.getArgument(0));

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, null);
        servicio.crear(clienteId, dto);

        // El empleado 2 tiene menos carga (2 < 5) → es el seleccionado.
        verify(empleadoDAO).findByIdConLock(2);
    }

    @Test
    void crear_sinEmpleado_descartaCandidatoSinHabilidades_lanzaIllegalState() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.emptyList());
        when(servicioDAO.findAllById(any())).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(any())).thenReturn(List.of(7));
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true))
                .thenReturn(List.of(empleado(1)));
        when(empleadoHabilidadDAO.contarHabilidadesQueCoinciden(any(), any())).thenReturn(0L);

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, null);

        assertThrows(IllegalStateException.class, () -> servicio.crear(clienteId, dto));
    }

    @Test
    void crear_sinEmpleado_descartaCandidatoQueNoTrabajaEnLaFranja_lanzaIllegalState() {
        int diaSemana = fechaFutura.getDayOfWeek().getValue();
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(clienteDAO.findById(clienteId)).thenReturn(Optional.of(cliente));
        when(reservaDAO.findReservasFuturasActivasPorCliente(any(), any(), any()))
                .thenReturn(Collections.emptyList());
        when(servicioDAO.findAllById(any())).thenReturn(List.of(servicio(1, 30)));
        when(servicioHabilidadDAO.obtenerHabilidadIdsRequeridas(any())).thenReturn(Collections.emptyList());
        when(empleadoDAO.findByOrganizacionAndActivo(organizacion, true))
                .thenReturn(List.of(empleado(1)));
        when(horarioEmpleadoDAO.findByEmpleadoAndDiaSemanaAndActivo(any(), eq(diaSemana), eq(true)))
                .thenReturn(Optional.empty());

        ReservaDTO dto = dto(List.of(1), t(10, 0), fechaFutura, null);

        assertThrows(IllegalStateException.class, () -> servicio.crear(clienteId, dto));
    }

    // ── actualizarEstado: máquina de estados ─────────────────────────────────

    @Test
    void actualizarEstado_pendienteAConfirmada_ok() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva(1, EstadoReserva.pendiente)));
        when(reservaDAO.save(any(Reserva.class))).thenAnswer(inv -> inv.getArgument(0));

        ReservaDTO resultado = servicio.actualizarEstado(1, EstadoReserva.confirmada);

        assertEquals(EstadoReserva.confirmada, resultado.getEstado());
    }

    @Test
    void actualizarEstado_confirmadaAPendiente_ok() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva(1, EstadoReserva.confirmada)));
        when(reservaDAO.save(any(Reserva.class))).thenAnswer(inv -> inv.getArgument(0));

        ReservaDTO resultado = servicio.actualizarEstado(1, EstadoReserva.pendiente);

        assertEquals(EstadoReserva.pendiente, resultado.getEstado());
    }

    @Test
    void actualizarEstado_pendienteACancelada_cancelaLasLineas() {
        Reserva reserva = reserva(1, EstadoReserva.pendiente);
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva));
        when(reservaDAO.save(any(Reserva.class))).thenAnswer(inv -> inv.getArgument(0));

        ReservaDTO resultado = servicio.actualizarEstado(1, EstadoReserva.cancelada);

        assertEquals(EstadoReserva.cancelada, resultado.getEstado());
        verify(reservaServicioDAO).cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
    }

    @Test
    void actualizarEstado_desdeEstadoFinal_lanzaIllegalState() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva(1, EstadoReserva.completada)));

        assertThrows(IllegalStateException.class,
                () -> servicio.actualizarEstado(1, EstadoReserva.pendiente));
    }

    // ── cancelar: restricciones del rol CLIENTE ──────────────────────────────

    @Test
    void cancelar_clienteSobreReservaDeOtro_lanzaRecursoNoEncontrado() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva(1, EstadoReserva.pendiente)));
        when(contextoSeguridad.obtenerUsuarioActual()).thenReturn(usuario(RolUsuario.CLIENTE));
        when(contextoSeguridad.obtenerClienteIdActual()).thenReturn(999);

        assertThrows(RecursoNoEncontradoException.class, () -> servicio.cancelar(1, "motivo"));
    }

    @Test
    void cancelar_clienteSobreReservaCompletada_lanzaIllegalState() {
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva(1, EstadoReserva.completada)));
        when(contextoSeguridad.obtenerUsuarioActual()).thenReturn(usuario(RolUsuario.CLIENTE));
        when(contextoSeguridad.obtenerClienteIdActual()).thenReturn(clienteId);

        assertThrows(IllegalStateException.class, () -> servicio.cancelar(1, "motivo"));
    }

    @Test
    void cancelar_clienteSobreSuReservaPendiente_cancelaLasLineas() {
        Reserva reserva = reserva(1, EstadoReserva.pendiente);
        when(contextoSeguridad.obtenerOrganizacionActual()).thenReturn(organizacion);
        when(reservaDAO.findById(1)).thenReturn(Optional.of(reserva));
        when(contextoSeguridad.obtenerUsuarioActual()).thenReturn(usuario(RolUsuario.CLIENTE));
        when(contextoSeguridad.obtenerClienteIdActual()).thenReturn(clienteId);

        servicio.cancelar(1, "ya no puedo");

        assertEquals(EstadoReserva.cancelada, reserva.getEstado());
        verify(reservaServicioDAO).cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private ReservaDTO dto(List<Integer> servicioIds, LocalTime hora, LocalDate fecha, Integer empleadoId) {
        ReservaDTO dto = new ReservaDTO();
        dto.setServicioIds(servicioIds);
        dto.setHoraInicio(hora);
        dto.setFecha(fecha);
        dto.setEmpleadoId(empleadoId);
        return dto;
    }

    private static LocalTime t(int hora, int minuto) {
        return LocalTime.of(hora, minuto);
    }

    private Organizacion org(int id) {
        Organizacion o = new Organizacion();
        o.setId(id);
        return o;
    }

    private Cliente cliente(int id) {
        Cliente c = new Cliente();
        c.setId(id);
        c.setOrganizacion(organizacion);
        c.setNombre("Cliente " + id);
        return c;
    }

    private Empleado empleado(int id) {
        Empleado e = new Empleado();
        e.setId(id);
        e.setOrganizacion(organizacion);
        e.setActivo(true);
        return e;
    }

    private Servicio servicio(int id, int duracionMinutos) {
        Servicio s = new Servicio();
        s.setId(id);
        s.setOrganizacion(organizacion);
        s.setActivo(true);
        s.setDuracionMinutos(duracionMinutos);
        return s;
    }

    private HorarioEmpleado horario(LocalTime inicio, LocalTime fin) {
        HorarioEmpleado h = new HorarioEmpleado();
        h.setHoraInicio(inicio);
        h.setHoraFin(fin);
        return h;
    }

    private Reserva reserva(int id, EstadoReserva estado) {
        Reserva r = new Reserva();
        r.setId(id);
        r.setOrganizacion(organizacion);
        r.setCliente(cliente);
        r.setEstado(estado);
        r.setFecha(fechaFutura);
        return r;
    }

    private Usuario usuario(RolUsuario rol) {
        Usuario u = new Usuario();
        u.setRol(rol);
        u.setOrganizacion(organizacion);
        return u;
    }
}
