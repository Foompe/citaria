package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementación del servicio de gestión de reservas.
 * Incluye gestión de líneas de detalle de cada reserva.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 */
@Service
public class ReservaServiceImpl implements ReservaService {

    private final ReservaDAO reservaDAO;
    private final ReservaServicioDAO reservaServicioDAO;
    private final ClienteDAO clienteDAO;
    private final ServicioDAO servicioDAO;
    private final EmpleadoDAO empleadoDAO;
    private final ContextoSeguridad contextoSeguridad;

    public ReservaServiceImpl(ReservaDAO reservaDAO,
                              ReservaServicioDAO reservaServicioDAO,
                              ClienteDAO clienteDAO,
                              ServicioDAO servicioDAO,
                              EmpleadoDAO empleadoDAO,
                              ContextoSeguridad contextoSeguridad) {
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.clienteDAO = clienteDAO;
        this.servicioDAO = servicioDAO;
        this.empleadoDAO = empleadoDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    // ===== RESERVA =====

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerTodas() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Reserva> reservas = reservaDAO.findByOrganizacion(organizacion);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorCliente(Integer clienteId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Cliente cliente = clienteDAO.findById(clienteId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + clienteId + " no encontrado"));
        verificarTenenciaCliente(cliente, organizacion);
        List<Reserva> reservas = reservaDAO.findByCliente(cliente);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorFecha(LocalDate fecha) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Reserva> reservas = reservaDAO.findByOrganizacionAndFecha(organizacion, fecha);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorEstado(EstadoReserva estado) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Reserva> reservas = reservaDAO.findByOrganizacionAndEstado(organizacion, estado);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public ReservaDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Reserva reserva = reservaDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Reserva con id " + id + " no encontrada"));
        verificarTenenciaReserva(reserva, organizacion);
        return convertirReservaADTO(reserva);
    }

    @Override
    @Transactional
    public ReservaDTO crear(Integer clienteId, ReservaDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Cliente cliente = clienteDAO.findById(clienteId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Cliente con id " + clienteId + " no encontrado"));
        verificarTenenciaCliente(cliente, organizacion);
        Reserva reserva = convertirReservaAEntidad(dto);
        reserva.setOrganizacion(organizacion);
        reserva.setCliente(cliente);
        return convertirReservaADTO(reservaDAO.save(reserva));
    }

    @Override
    @Transactional
    public ReservaDTO actualizarEstado(Integer id, EstadoReserva estado) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Reserva reserva = reservaDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Reserva con id " + id + " no encontrada"));
        verificarTenenciaReserva(reserva, organizacion);
        reserva.setEstado(estado);
        return convertirReservaADTO(reservaDAO.save(reserva));
    }

    /**
     * {@inheritDoc}
     *
     * Cancela las líneas activas via JPQL bulk update antes de cancelar la cabecera,
     * todo en la misma transacción para garantizar consistencia.
     */
    @Override
    @Transactional
    public void eliminar(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Reserva reserva = reservaDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Reserva con id " + id + " no encontrada"));
        verificarTenenciaReserva(reserva, organizacion);
        reservaServicioDAO.cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
        reserva.setEstado(EstadoReserva.cancelada);
    }

    // ===== LÍNEAS DE DETALLE =====

    @Override
    @Transactional(readOnly = true)
    public List<ReservaServicioDTO> obtenerDetallesPorReserva(Integer reservaId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Reserva reserva = reservaDAO.findById(reservaId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Reserva con id " + reservaId + " no encontrada"));
        verificarTenenciaReserva(reserva, organizacion);
        List<ReservaServicio> detalles = reservaServicioDAO.findByReserva(reserva);
        List<ReservaServicioDTO> detallesDTO = new ArrayList<>();
        for (ReservaServicio detalle : detalles) {
            detallesDTO.add(convertirDetalleADTO(detalle));
        }
        return detallesDTO;
    }

    @Override
    @Transactional
    public ReservaServicioDTO agregarDetalle(Integer reservaId, ReservaServicioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Reserva reserva = reservaDAO.findById(reservaId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Reserva con id " + reservaId + " no encontrada"));
        verificarTenenciaReserva(reserva, organizacion);
        Servicio servicio = servicioDAO.findById(dto.getServicioId())
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Servicio con id " + dto.getServicioId() + " no encontrado"));
        Empleado empleado = empleadoDAO.findById(dto.getEmpleadoId())
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + dto.getEmpleadoId() + " no encontrado"));
        ReservaServicio detalle = convertirDetalleAEntidad(dto);
        detalle.setReserva(reserva);
        detalle.setServicio(servicio);
        detalle.setEmpleado(empleado);
        return convertirDetalleADTO(reservaServicioDAO.save(detalle));
    }

    @Override
    @Transactional
    public void eliminarDetalle(Integer id) {
        ReservaServicio detalle = reservaServicioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Línea de detalle con id " + id + " no encontrada"));
        detalle.setEstado(EstadoReservaServicio.cancelado);
    }

    // ===== VERIFICACIÓN DE TENENCIA =====

    private void verificarTenenciaReserva(Reserva reserva, Organizacion organizacion) {
        if (!reserva.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Reserva con id " + reserva.getId() + " no encontrada");
        }
    }

    private void verificarTenenciaCliente(Cliente cliente, Organizacion organizacion) {
        if (!cliente.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Cliente con id " + cliente.getId() + " no encontrado");
        }
    }

    // ===== CONVERSIONES =====

    private ReservaDTO convertirReservaADTO(Reserva reserva) {
        ReservaDTO dto = new ReservaDTO();
        dto.setId(reserva.getId());
        dto.setOrganizacionId(reserva.getOrganizacion().getId());
        dto.setClienteId(reserva.getCliente().getId());
        dto.setNombreCliente(reserva.getCliente().getNombre() + " " +
                (reserva.getCliente().getApellidos() != null ? reserva.getCliente().getApellidos() : ""));
        dto.setEstado(reserva.getEstado());
        dto.setFecha(reserva.getFecha());
        dto.setNotas(reserva.getNotas());
        return dto;
    }

    private Reserva convertirReservaAEntidad(ReservaDTO dto) {
        Reserva reserva = new Reserva();
        reserva.setFecha(dto.getFecha());
        reserva.setNotas(dto.getNotas());
        reserva.setEstado(dto.getEstado() != null ? dto.getEstado() : EstadoReserva.pendiente);
        return reserva;
    }

    private ReservaServicioDTO convertirDetalleADTO(ReservaServicio detalle) {
        ReservaServicioDTO dto = new ReservaServicioDTO();
        dto.setId(detalle.getId());
        dto.setReservaId(detalle.getReserva().getId());
        dto.setServicioId(detalle.getServicio().getId());
        dto.setNombreServicio(detalle.getServicio().getNombre());
        dto.setEmpleadoId(detalle.getEmpleado().getId());
        dto.setNombreEmpleado(detalle.getEmpleado().getNombre() + " " + detalle.getEmpleado().getApellidos());
        dto.setHoraInicio(detalle.getHoraInicio());
        dto.setHoraFin(detalle.getHoraFin());
        dto.setPrecioUnitario(detalle.getPrecioUnitario());
        dto.setCantidad(detalle.getCantidad());
        dto.setEstado(detalle.getEstado());
        return dto;
    }

    private ReservaServicio convertirDetalleAEntidad(ReservaServicioDTO dto) {
        ReservaServicio detalle = new ReservaServicio();
        detalle.setHoraInicio(dto.getHoraInicio());
        detalle.setHoraFin(dto.getHoraFin());
        detalle.setPrecioUnitario(dto.getPrecioUnitario());
        detalle.setCantidad(dto.getCantidad() != null ? dto.getCantidad() : 1);
        detalle.setEstado(EstadoReservaServicio.activo);
        return detalle;
    }
}