package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.model.*;
import com.citaria.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de reservas.
 * Incluye gestión de líneas de detalle de cada reserva.
 */
@Service
public class ReservaServiceImpl implements ReservaService {

    private ReservaDAO reservaDAO;
    private ReservaServicioDAO reservaServicioDAO;
    private ClienteDAO clienteDAO;
    private ServicioDAO servicioDAO;
    private EmpleadoDAO empleadoDAO;
    private OrganizacionDAO organizacionDAO;

    @Autowired
    public ReservaServiceImpl(ReservaDAO reservaDAO,
                              ReservaServicioDAO reservaServicioDAO,
                              ClienteDAO clienteDAO,
                              ServicioDAO servicioDAO,
                              EmpleadoDAO empleadoDAO,
                              OrganizacionDAO organizacionDAO) {
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.clienteDAO = clienteDAO;
        this.servicioDAO = servicioDAO;
        this.empleadoDAO = empleadoDAO;
        this.organizacionDAO = organizacionDAO;
    }

    // ===== RESERVA =====

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerTodas(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Reserva> reservas = reservaDAO.findByOrganizacion(organizacion.get());
            for (Reserva reserva : reservas) {
                reservasDTO.add(convertirReservaADTO(reserva));
            }
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorCliente(Integer clienteId) {
        Optional<Cliente> cliente = clienteDAO.findById(clienteId);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        if (cliente.isPresent()) {
            List<Reserva> reservas = reservaDAO.findByCliente(cliente.get());
            for (Reserva reserva : reservas) {
                reservasDTO.add(convertirReservaADTO(reserva));
            }
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorFecha(Integer organizacionId, LocalDate fecha) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Reserva> reservas = reservaDAO.findByOrganizacionAndFecha(organizacion.get(), fecha);
            for (Reserva reserva : reservas) {
                reservasDTO.add(convertirReservaADTO(reserva));
            }
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorEstado(Integer organizacionId, EstadoReserva estado) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Reserva> reservas = reservaDAO.findByOrganizacionAndEstado(organizacion.get(), estado);
            for (Reserva reserva : reservas) {
                reservasDTO.add(convertirReservaADTO(reserva));
            }
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ReservaDTO> obtenerPorId(Integer id) {
        Optional<Reserva> reserva = reservaDAO.findById(id);
        if (reserva.isPresent()) {
            return Optional.of(convertirReservaADTO(reserva.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public ReservaDTO crear(Integer organizacionId, Integer clienteId, ReservaDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Optional<Cliente> cliente = clienteDAO.findById(clienteId);
        Reserva reserva = convertirReservaAEntidad(dto);
        reserva.setOrganizacion(organizacion.get());
        reserva.setCliente(cliente.get());
        return convertirReservaADTO(reservaDAO.save(reserva));
    }

    @Override
    @Transactional
    public Optional<ReservaDTO> actualizarEstado(Integer id, EstadoReserva estado) {
        Optional<Reserva> existente = reservaDAO.findById(id);
        if (existente.isPresent()) {
            Reserva reserva = existente.get();
            reserva.setEstado(estado);
            return Optional.of(convertirReservaADTO(reservaDAO.save(reserva)));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public boolean eliminar(Integer id) {
        if (reservaDAO.existsById(id)) {
            reservaDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== LÍNEAS DE DETALLE =====

    @Override
    @Transactional(readOnly = true)
    public List<ReservaServicioDTO> obtenerDetallesPorReserva(Integer reservaId) {
        Optional<Reserva> reserva = reservaDAO.findById(reservaId);
        List<ReservaServicioDTO> detallesDTO = new ArrayList<>();
        if (reserva.isPresent()) {
            List<ReservaServicio> detalles = reservaServicioDAO.findByReserva(reserva.get());
            for (ReservaServicio detalle : detalles) {
                detallesDTO.add(convertirDetalleADTO(detalle));
            }
        }
        return detallesDTO;
    }

    @Override
    @Transactional
    public ReservaServicioDTO agregarDetalle(Integer reservaId, ReservaServicioDTO dto) {
        Optional<Reserva> reserva = reservaDAO.findById(reservaId);
        Optional<Servicio> servicio = servicioDAO.findById(dto.getServicioId());
        Optional<Empleado> empleado = empleadoDAO.findById(dto.getEmpleadoId());
        ReservaServicio detalle = convertirDetalleAEntidad(dto);
        detalle.setReserva(reserva.get());
        detalle.setServicio(servicio.get());
        detalle.setEmpleado(empleado.get());
        return convertirDetalleADTO(reservaServicioDAO.save(detalle));
    }

    @Override
    @Transactional
    public boolean eliminarDetalle(Integer id) {
        if (reservaServicioDAO.existsById(id)) {
            reservaServicioDAO.deleteById(id);
            return true;
        }
        return false;
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
        return dto;
    }

    private ReservaServicio convertirDetalleAEntidad(ReservaServicioDTO dto) {
        ReservaServicio detalle = new ReservaServicio();
        detalle.setHoraInicio(dto.getHoraInicio());
        detalle.setHoraFin(dto.getHoraFin());
        detalle.setPrecioUnitario(dto.getPrecioUnitario());
        detalle.setCantidad(dto.getCantidad() != null ? dto.getCantidad() : 1);
        return detalle;
    }
}