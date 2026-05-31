package com.citaria.service;

import com.citaria.dto.EstadisticaItemDTO;
import com.citaria.dto.EstadisticaMesDTO;
import com.citaria.dto.ResumenEstadisticaDTO;
import com.citaria.repository.EstadisticaDAO;
import com.citaria.repository.projection.FilaItemEstadistica;
import com.citaria.repository.projection.FilaMesEstadistica;
import com.citaria.security.ContextoSeguridad;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests de estadísticas. El foco es el cálculo de porcentajes con guarda de
 * división por cero y redondeo a dos decimales (lógica repetida en varios
 * métodos), el emparejamiento por período de clientes y el resumen. Los DAOs
 * devuelven proyecciones (interfaces), que se mockean campo a campo. Los
 * métodos de mapeo plano (importes, servicios más solicitados) quedan fuera.
 */
@ExtendWith(MockitoExtension.class)
class EstadisticaServiceImplTest {

    @Mock private EstadisticaDAO estadisticaDAO;
    @Mock private ContextoSeguridad contextoSeguridad;

    @InjectMocks private EstadisticaServiceImpl servicio;

    private final LocalDate desde = LocalDate.of(2026, 1, 1);
    private final LocalDate hasta = LocalDate.of(2026, 3, 31);

    @BeforeEach
    void setUp() {
        when(contextoSeguridad.obtenerOrganizacionIdActual()).thenReturn(1);
    }

    // ── Porcentaje: cálculo, redondeo y división por cero ────────────────────

    @Test
    void reservasPorEmpleado_calculaPorcentajeYRedondea() {
        FilaItemEstadistica fila = itemFila(10, "Ana", 3.0, 1.0);
        when(estadisticaDAO.reservasPorEmpleado(eq(1), any(), any())).thenReturn(List.of(fila));

        EstadisticaItemDTO dto = servicio.reservasPorEmpleado(desde, hasta).get(0);

        // valor = total de reservas; porcentaje = 1/3*100 = 33.33 (2 decimales).
        assertEquals(3.0, dto.getValor(), 0.0001);
        assertEquals(33.33, dto.getPorcentaje(), 0.0001);
    }

    @Test
    void reservasPorEmpleado_totalCero_porcentajeCero() {
        FilaItemEstadistica fila = itemFila(10, "Ana", 0.0, 0.0);
        when(estadisticaDAO.reservasPorEmpleado(eq(1), any(), any())).thenReturn(List.of(fila));

        EstadisticaItemDTO dto = servicio.reservasPorEmpleado(desde, hasta).get(0);

        // total = 0 → no debe dividir por cero, el porcentaje es 0.0.
        assertEquals(0.0, dto.getValor(), 0.0001);
        assertEquals(0.0, dto.getPorcentaje(), 0.0001);
    }

    @Test
    void cancelacionesPorEmpleado_valorEsLasCanceladas() {
        FilaItemEstadistica fila = itemFila(10, "Ana", 4.0, 1.0);
        when(estadisticaDAO.cancelacionesPorEmpleado(eq(1), any(), any())).thenReturn(List.of(fila));

        EstadisticaItemDTO dto = servicio.cancelacionesPorEmpleado(desde, hasta).get(0);

        // Aquí el valor expuesto son las canceladas (no el total); porcentaje 25.0.
        assertEquals(1.0, dto.getValor(), 0.0001);
        assertEquals(25.0, dto.getPorcentaje(), 0.0001);
    }

    @Test
    void fidelizacion_calculaRetencionYRedondea() {
        FilaMesEstadistica fila = filaFidelizacion("2026-01", 3.0, 2.0);
        when(estadisticaDAO.calcularFidelizacionPorMes(eq(1), any(), any())).thenReturn(List.of(fila));

        EstadisticaMesDTO dto = servicio.fidelizacionClientes(desde, hasta).get(0);

        // valor1 = total clientes; valor2 = 2/3*100 = 66.67.
        assertEquals(3.0, dto.getValor1(), 0.0001);
        assertEquals(66.67, dto.getValor2(), 0.0001);
    }

    @Test
    void fidelizacion_totalCero_retencionCero() {
        FilaMesEstadistica fila = filaFidelizacion("2026-01", 0.0, 0.0);
        when(estadisticaDAO.calcularFidelizacionPorMes(eq(1), any(), any())).thenReturn(List.of(fila));

        EstadisticaMesDTO dto = servicio.fidelizacionClientes(desde, hasta).get(0);

        assertEquals(0.0, dto.getValor2(), 0.0001);
    }

    // ── Emparejamiento por período ───────────────────────────────────────────

    @Test
    void clientesNuevosVsRecurrentes_emparejaPorPeriodoYRellenaConCero() {
        FilaMesEstadistica nuevo1 = filaMensual("2026-01", 5.0);
        FilaMesEstadistica nuevo2 = filaMensual("2026-02", 3.0);
        FilaMesEstadistica recurrente1 = filaMensual("2026-01", 2.0);
        when(estadisticaDAO.contarClientesNuevosPorMes(eq(1), any(), any()))
                .thenReturn(List.of(nuevo1, nuevo2));
        when(estadisticaDAO.contarClientesRecurrentesPorMes(eq(1), any(), any()))
                .thenReturn(List.of(recurrente1));

        List<EstadisticaMesDTO> resultado = servicio.clientesNuevosVsRecurrentes(desde, hasta);

        assertEquals(2, resultado.size());
        // 2026-01 tiene recurrentes (2.0); 2026-02 no aparece en recurrentes → 0.0.
        assertEquals(5.0, resultado.get(0).getValor1(), 0.0001);
        assertEquals(2.0, resultado.get(0).getValor2(), 0.0001);
        assertEquals(3.0, resultado.get(1).getValor1(), 0.0001);
        assertEquals(0.0, resultado.get(1).getValor2(), 0.0001);
    }

    // ── Resumen ──────────────────────────────────────────────────────────────

    @Test
    void obtenerResumen_facturacionNula_seNormalizaACero() {
        when(estadisticaDAO.contarReservasPorFecha(eq(1), any())).thenReturn(3L);
        when(estadisticaDAO.contarReservasPorMes(eq(1), anyInt(), anyInt())).thenReturn(50L);
        when(estadisticaDAO.contarClientesNuevosMes(eq(1), any(), any())).thenReturn(2L);
        when(estadisticaDAO.servicioMasSolicitadoMes(eq(1), anyInt(), anyInt())).thenReturn("Corte");
        // facturacionPorFecha/Mes se dejan sin stubear → devuelven null por defecto.

        ResumenEstadisticaDTO dto = servicio.obtenerResumen();

        assertEquals(BigDecimal.ZERO, dto.getFacturacionHoy());
        assertEquals(BigDecimal.ZERO, dto.getFacturacionMes());
        assertEquals(3L, dto.getReservasHoy());
        assertEquals("Corte", dto.getServicioMasSolicitadoMes());
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private FilaItemEstadistica itemFila(Integer id, String nombre, Double total, Double canceladas) {
        FilaItemEstadistica fila = mock(FilaItemEstadistica.class);
        when(fila.getId()).thenReturn(id);
        when(fila.getNombre()).thenReturn(nombre);
        when(fila.getTotal()).thenReturn(total);
        when(fila.getCanceladas()).thenReturn(canceladas);
        return fila;
    }

    /** Para fidelización: el servicio lee período, valor1 y valor2. */
    private FilaMesEstadistica filaFidelizacion(String periodo, Double total, Double repiten) {
        FilaMesEstadistica fila = mock(FilaMesEstadistica.class);
        when(fila.getPeriodo()).thenReturn(periodo);
        when(fila.getValor1()).thenReturn(total);
        when(fila.getValor2()).thenReturn(repiten);
        return fila;
    }

    /** Para nuevos/recurrentes: el servicio solo lee período y valor1. */
    private FilaMesEstadistica filaMensual(String periodo, Double valor1) {
        FilaMesEstadistica fila = mock(FilaMesEstadistica.class);
        when(fila.getPeriodo()).thenReturn(periodo);
        when(fila.getValor1()).thenReturn(valor1);
        return fila;
    }
}
