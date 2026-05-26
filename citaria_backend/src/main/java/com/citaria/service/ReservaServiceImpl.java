package com.citaria.service;

import com.citaria.dto.ReservaDTO;
import com.citaria.dto.ReservaServicioDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de reservas.
 */
@Service
public class ReservaServiceImpl implements ReservaService {

    private final ReservaDAO reservaDAO;
    private final ReservaServicioDAO reservaServicioDAO;
    private final ClienteDAO clienteDAO;
    private final ServicioDAO servicioDAO;
    private final EmpleadoDAO empleadoDAO;
    private final EmpleadoSkillDAO empleadoSkillDAO;
    private final ServicioSkillDAO servicioSkillDAO;
    private final ContextoSeguridad contextoSeguridad;

    @Autowired
    public ReservaServiceImpl(ReservaDAO reservaDAO,
                              ReservaServicioDAO reservaServicioDAO,
                              ClienteDAO clienteDAO,
                              ServicioDAO servicioDAO,
                              EmpleadoDAO empleadoDAO,
                              EmpleadoSkillDAO empleadoSkillDAO,
                              ServicioSkillDAO servicioSkillDAO,
                              ContextoSeguridad contextoSeguridad) {
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.clienteDAO = clienteDAO;
        this.servicioDAO = servicioDAO;
        this.empleadoDAO = empleadoDAO;
        this.empleadoSkillDAO = empleadoSkillDAO;
        this.servicioSkillDAO = servicioSkillDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    // ADMIN — carga con líneas incluidas (sin N+1)

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerAdminPorFecha(LocalDate fechaInicio,
                                                  LocalDate fechaFin,
                                                  List<EstadoReserva> estados) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Reserva> reservas;
        if (estados == null || estados.isEmpty()) {
            reservas = reservaDAO.findAdminPorFecha(organizacion, fechaInicio, fechaFin);
        } else {
            reservas = reservaDAO.findAdminPorFechaYEstados(organizacion, fechaInicio, fechaFin, estados);
        }
        return convertirConLineas(reservas);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReservaDTO> obtenerAdminPorEstado(EstadoReserva estado, int pagina, int tamano) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Pageable pageable = PageRequest.of(pagina, tamano);
        Page<Reserva> paginaReservas = reservaDAO
                .findByOrganizacionAndEstadoOrderByFechaDesc(organizacion, estado, pageable);
        List<ReservaDTO> dtos = convertirConLineas(paginaReservas.getContent());
        return new PageImpl<>(dtos, pageable, paginaReservas.getTotalElements());
    }

    // RESERVA

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorCliente(Integer clienteId) {
        Usuario usuario = contextoSeguridad.obtenerUsuarioActual();
        Organizacion organizacion = usuario.getOrganizacion();
        Optional<Cliente> clienteOptional = clienteDAO.findById(clienteId);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + clienteId + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarPertenenciaCliente(cliente, organizacion);
        if (usuario.getRol() == RolUsuario.CLIENTE
                && (usuario.getCliente() == null || !usuario.getCliente().getId().equals(clienteId))) {
            throw new RecursoNoEncontradoException("Cliente con id " + clienteId + " no encontrado");
        }
        List<Reserva> reservas = reservaDAO.findByCliente(cliente);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerPorFechaYEstados(LocalDate fecha, List<EstadoReserva> estados) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Reserva> reservas;
        if (estados == null || estados.isEmpty()) {
            reservas = reservaDAO.findByOrganizacionAndFecha(organizacion, fecha);
        } else {
            reservas = reservaDAO.findByOrganizacionAndFechaAndEstadoIn(organizacion, fecha, estados);
        }
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
        Optional<Reserva> reservaOptional = reservaDAO.findById(id);
        if (reservaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Reserva con id " + id + " no encontrada");
        }
        Reserva reserva = reservaOptional.get();
        verificarPertenenciaReserva(reserva, organizacion);
        return convertirReservaADTO(reserva);
    }

    /**
     * Si no se indica empleadoId en el DTO, el sistema asigna automáticamente
     * al empleado con menos reservas ese día que cumpla los requisitos de skill.
     */
    @Override
    @Transactional
    public ReservaDTO crear(Integer clienteId, ReservaDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Cliente> clienteOptional = clienteDAO.findById(clienteId);
        if (clienteOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cliente con id " + clienteId + " no encontrado");
        }
        Cliente cliente = clienteOptional.get();
        verificarPertenenciaCliente(cliente, organizacion);

        if (dto.getServicioIds() == null || dto.getServicioIds().isEmpty()) {
            throw new IllegalStateException("Debe seleccionar al menos un servicio");
        }
        if (dto.getHoraInicio() == null) {
            throw new IllegalStateException("La hora de inicio es obligatoria");
        }

        // Resolver empleado — manual o automático
        Empleado empleado = buscarEmpleadoDisponible(dto, organizacion);

        List<Servicio> servicios = servicioDAO.findAllById(dto.getServicioIds());
        LocalTime horaFinReserva = dto.getHoraInicio();
        for (Servicio servicio : servicios) {
            verificarPertenenciaServicio(servicio, organizacion);
            if (!Boolean.TRUE.equals(servicio.getActivo())) {
                throw new RecursoNoEncontradoException("Servicio con id " + servicio.getId() + " no encontrado");
            }
            horaFinReserva = horaFinReserva.plusMinutes(servicio.getDuracionMinutos());
        }

        long solapamientos = reservaServicioDAO.contarSolapamientos(
                empleado.getId(), dto.getFecha(), dto.getHoraInicio(), horaFinReserva);
        if (solapamientos > 0) {
            throw new IllegalStateException("No hay disponibilidad para el horario solicitado");
        }

        // Crear cabecera de reserva
        Reserva reserva = crearCabeceraReserva(dto, organizacion, cliente);
        reserva = reservaDAO.save(reserva);

        // Crear líneas de detalle acumulando duraciones — una sola query para todos los servicios
        LocalTime horaActual = dto.getHoraInicio();
        for (Servicio servicio : servicios) {
            LocalTime horaFinServicio = horaActual.plusMinutes(servicio.getDuracionMinutos());
            ReservaServicio detalle = crearDetalleReserva(reserva, servicio, empleado, horaActual, horaFinServicio);
            reservaServicioDAO.save(detalle);
            horaActual = horaFinServicio;
        }

        return convertirReservaADTO(reserva);
    }

    // MÉTODOS AUXILIARES

    /**
     * Busca el empleado para la reserva.
     */
    private Empleado buscarEmpleadoDisponible(ReservaDTO dto, Organizacion organizacion) {
        if (dto.getEmpleadoId() != null) {
            Optional<Empleado> empleadoOptional = empleadoDAO.findById(dto.getEmpleadoId());
            if (empleadoOptional.isEmpty()) {
                throw new RecursoNoEncontradoException("Empleado con id " + dto.getEmpleadoId() + " no encontrado");
            }
            Empleado empleado = empleadoOptional.get();
            verificarPertenenciaEmpleado(empleado, organizacion);
            return empleado;
        }

        // Asignación automática — menor carga entre empleados válidos
        List<Integer> skillsRequeridas = servicioSkillDAO.obtenerSkillIdsRequeridas(dto.getServicioIds());
        List<Empleado> candidatos = empleadoDAO.findByOrganizacionAndActivo(organizacion, true);

        Empleado seleccionado = null;
        long menorCarga = Long.MAX_VALUE;

        for (Empleado candidato : candidatos) {
            if (!skillsRequeridas.isEmpty()) {
                long skillsQueElEmpleadoTiene = empleadoSkillDAO
                        .contarSkillsQueCoinciden(candidato, skillsRequeridas);
                if (skillsQueElEmpleadoTiene < skillsRequeridas.size()) {
                    continue;
                }
            }
            long carga = reservaServicioDAO.contarReservasPorEmpleadoYFecha(candidato.getId(), dto.getFecha());
            if (carga < menorCarga) {
                menorCarga = carga;
                seleccionado = candidato;
            }
        }

        if (seleccionado == null) {
            throw new IllegalStateException("No hay ningún empleado disponible con las skills requeridas para esa fecha");
        }
        return seleccionado;
    }

    /**
     * Construye la cabecera de una reserva a partir del DTO y las entidades resueltas.
     *
     * @param dto          datos de la reserva
     * @param organizacion organización de la reserva
     * @param cliente      cliente de la reserva
     * @return reserva
     */
    private Reserva crearCabeceraReserva(ReservaDTO dto,
                                         Organizacion organizacion,
                                         Cliente cliente) {
        Reserva reserva = new Reserva();
        reserva.setOrganizacion(organizacion);
        reserva.setCliente(cliente);
        reserva.setFecha(dto.getFecha());
        reserva.setNotas(dto.getNotas());
        reserva.setEstado(EstadoReserva.pendiente);
        return reserva;
    }

    /**
     * Construye una línea de detalle de reserva.
     *
     * @param reserva    cabecera de la reserva
     * @param servicio   servicio de la línea
     * @param empleado   empleado asignado
     * @param horaInicio hora de inicio de la línea
     * @param horaFin    hora de fin de la línea
     * @return detalle listo para persistir
     */
    private ReservaServicio crearDetalleReserva(Reserva reserva,
                                                Servicio servicio,
                                                Empleado empleado,
                                                LocalTime horaInicio,
                                                LocalTime horaFin) {
        ReservaServicio detalle = new ReservaServicio();
        detalle.setReserva(reserva);
        detalle.setServicio(servicio);
        detalle.setEmpleado(empleado);
        detalle.setHoraInicio(horaInicio);
        detalle.setHoraFin(horaFin);
        detalle.setPrecioUnitario(servicio.getPrecio());
        detalle.setCantidad(1);
        detalle.setEstado(EstadoReservaServicio.activo);
        return detalle;
    }

    @Override
    @Transactional
    public ReservaDTO actualizarEstado(Integer id, EstadoReserva estado) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Reserva> reservaOptional = reservaDAO.findById(id);
        if (reservaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Reserva con id " + id + " no encontrada");
        }
        Reserva reserva = reservaOptional.get();
        verificarPertenenciaReserva(reserva, organizacion);
        reserva.setEstado(estado);
        return convertirReservaADTO(reservaDAO.save(reserva));
    }

    @Override
    @Transactional
    public void cancelar(Integer id, String motivo) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Reserva> reservaOptional = reservaDAO.findById(id);
        if (reservaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Reserva con id " + id + " no encontrada");
        }
        Reserva reserva = reservaOptional.get();
        verificarPertenenciaReserva(reserva, organizacion);

        Usuario usuario = contextoSeguridad.obtenerUsuarioActual();
        if (usuario.getRol() == RolUsuario.CLIENTE) {
            if (!reserva.getCliente().getId().equals(contextoSeguridad.obtenerClienteIdActual())) {
                throw new RecursoNoEncontradoException("Reserva con id " + id + " no encontrada");
            }
            if (reserva.getEstado() != EstadoReserva.pendiente
                    && reserva.getEstado() != EstadoReserva.confirmada) {
                throw new IllegalStateException("Solo puedes cancelar reservas en estado pendiente o confirmada");
            }
        }

        reserva.setEstado(EstadoReserva.cancelada);
        reserva.setMotivo(motivo);
        reservaServicioDAO.cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
    }

    // LÍNEAS DE RESERVA

    @Override
    @Transactional(readOnly = true)
    public List<ReservaServicioDTO> obtenerLineasPorReserva(Integer reservaId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Reserva> reservaOptional = reservaDAO.findById(reservaId);
        if (reservaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Reserva con id " + reservaId + " no encontrada");
        }
        Reserva reserva = reservaOptional.get();
        verificarPertenenciaReserva(reserva, organizacion);
        List<ReservaServicio> detalles = reservaServicioDAO.findByReserva(reserva);
        List<ReservaServicioDTO> detallesDTO = new ArrayList<>();
        for (ReservaServicio detalle : detalles) {
            detallesDTO.add(convertirLineaADTO(detalle));
        }
        return detallesDTO;
    }

    @Override
    @Transactional
    public ReservaServicioDTO agregarLineaAReserva(Integer reservaId, ReservaServicioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Reserva> reservaOptional = reservaDAO.findById(reservaId);
        if (reservaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Reserva con id " + reservaId + " no encontrada");
        }
        Reserva reserva = reservaOptional.get();
        verificarPertenenciaReserva(reserva, organizacion);
        Optional<Servicio> servicioOptional = servicioDAO.findById(dto.getServicioId());
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + dto.getServicioId() + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPertenenciaServicio(servicio, organizacion);
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(dto.getEmpleadoId());
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + dto.getEmpleadoId() + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenenciaEmpleado(empleado, organizacion);
        ReservaServicio detalle = convertirLineaAEntidad(dto);
        detalle.setReserva(reserva);
        detalle.setServicio(servicio);
        detalle.setEmpleado(empleado);
        return convertirLineaADTO(reservaServicioDAO.save(detalle));
    }

    @Override
    @Transactional
    public void eliminarLinea(Integer reservaId, Integer detalleId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<ReservaServicio> detalleOptional = reservaServicioDAO.findById(detalleId);
        if (detalleOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Línea de detalle con id " + detalleId + " no encontrada");
        }
        ReservaServicio detalle = detalleOptional.get();
        verificarPertenenciaReserva(detalle.getReserva(), organizacion);
        if (!detalle.getReserva().getId().equals(reservaId)) {
            throw new RecursoNoEncontradoException(
                    "Línea de detalle con id " + detalleId + " no encontrada");
        }
        detalle.setEstado(EstadoReservaServicio.cancelado);
        reservaServicioDAO.save(detalle);
    }

    @Override
    @Transactional
    public ReservaServicioDTO reasignarEmpleadoDetalle(Integer reservaId, Integer detalleId, Integer nuevoEmpleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<ReservaServicio> detalleOptional = reservaServicioDAO.findById(detalleId);
        if (detalleOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Línea de detalle con id " + detalleId + " no encontrada");
        }
        ReservaServicio detalle = detalleOptional.get();
        verificarPertenenciaReserva(detalle.getReserva(), organizacion);
        if (!detalle.getReserva().getId().equals(reservaId)) {
            throw new RecursoNoEncontradoException(
                    "Línea de detalle con id " + detalleId + " no encontrada");
        }
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(nuevoEmpleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + nuevoEmpleadoId + " no encontrado");
        }
        Empleado nuevoEmpleado = empleadoOptional.get();
        verificarPertenenciaEmpleado(nuevoEmpleado, organizacion);
        detalle.setEmpleado(nuevoEmpleado);
        return convertirLineaADTO(reservaServicioDAO.save(detalle));
    }

    //MÉTODOS AUXILIARES

    // VERIFICACIÓN DE PERTENENCIA

    private void verificarPertenenciaReserva(Reserva reserva, Organizacion organizacion) {
        if (!reserva.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Reserva con id " + reserva.getId() + " no encontrada");
        }
    }

    private void verificarPertenenciaCliente(Cliente cliente, Organizacion organizacion) {
        if (!cliente.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Cliente con id " + cliente.getId() + " no encontrado");
        }
    }

    private void verificarPertenenciaEmpleado(Empleado empleado, Organizacion organizacion) {
        if (!empleado.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleado.getId() + " no encontrado");
        }
    }

    private void verificarPertenenciaServicio(Servicio servicio, Organizacion organizacion) {
        if (!servicio.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicio.getId() + " no encontrado");
        }
    }

    // CONVERSIONES

    private List<ReservaDTO> convertirConLineas(List<Reserva> reservas) {
        if (reservas.isEmpty()) {
            return new ArrayList<>();
        }
        Map<Integer, List<ReservaServicio>> lineasPorReserva = new HashMap<>();
        for (ReservaServicio rs : reservaServicioDAO.findByReservaIn(reservas)) {
            lineasPorReserva
                    .computeIfAbsent(rs.getReserva().getId(), k -> new ArrayList<>())
                    .add(rs);
        }
        List<ReservaDTO> dtos = new ArrayList<>();
        for (Reserva reserva : reservas) {
            List<ReservaServicio> lineas = lineasPorReserva
                    .getOrDefault(reserva.getId(), new ArrayList<>());
            dtos.add(convertirReservaADTOConLineas(reserva, lineas));
        }
        return dtos;
    }

    private ReservaDTO convertirReservaADTOConLineas(Reserva reserva, List<ReservaServicio> lineas) {
        ReservaDTO dto = new ReservaDTO();
        dto.setId(reserva.getId());
        dto.setOrganizacionId(reserva.getOrganizacion().getId());
        dto.setClienteId(reserva.getCliente().getId());
        String apellidos = reserva.getCliente().getApellidos();
        if (apellidos != null) {
            dto.setNombreCliente(reserva.getCliente().getNombre() + " " + apellidos);
        } else {
            dto.setNombreCliente(reserva.getCliente().getNombre());
        }
        dto.setEstado(reserva.getEstado());
        dto.setFecha(reserva.getFecha());
        if (!lineas.isEmpty()) {
            dto.setHoraInicio(lineas.get(0).getHoraInicio());
            dto.setEmpleadoId(obtenerEmpleadoComun(lineas));
        }
        List<Integer> servicioIds = new ArrayList<>();
        List<ReservaServicioDTO> lineasDTO = new ArrayList<>();
        for (ReservaServicio linea : lineas) {
            if (linea.getServicio() != null) {
                servicioIds.add(linea.getServicio().getId());
            }
            lineasDTO.add(convertirLineaADTO(linea));
        }
        dto.setServicioIds(servicioIds);
        dto.setLineas(lineasDTO);
        dto.setNotas(reserva.getNotas());
        dto.setMotivo(reserva.getMotivo());
        return dto;
    }

    private ReservaDTO convertirReservaADTO(Reserva reserva) {
        ReservaDTO dto = new ReservaDTO();
        dto.setId(reserva.getId());
        dto.setOrganizacionId(reserva.getOrganizacion().getId());
        dto.setClienteId(reserva.getCliente().getId());
        String apellidos = reserva.getCliente().getApellidos();
        if (apellidos != null) {
            dto.setNombreCliente(reserva.getCliente().getNombre() + " " + apellidos);
        } else {
            dto.setNombreCliente(reserva.getCliente().getNombre());
        }
        dto.setEstado(reserva.getEstado());
        dto.setFecha(reserva.getFecha());
        List<ReservaServicio> detalles = reservaServicioDAO.findByReserva(reserva);
        if (!detalles.isEmpty()) {
            dto.setHoraInicio(detalles.get(0).getHoraInicio());
            dto.setEmpleadoId(obtenerEmpleadoComun(detalles));
        }
        List<Integer> servicioIds = new ArrayList<>();
        List<ReservaServicioDTO> lineasDTO = new ArrayList<>();
        for (ReservaServicio detalle : detalles) {
            if (detalle.getServicio() != null) {
                servicioIds.add(detalle.getServicio().getId());
            }
            lineasDTO.add(convertirLineaADTO(detalle));
        }
        dto.setServicioIds(servicioIds);
        dto.setLineas(lineasDTO);
        dto.setNotas(reserva.getNotas());
        dto.setMotivo(reserva.getMotivo());
        return dto;
    }

    private Integer obtenerEmpleadoComun(List<ReservaServicio> detalles) {
        Integer empleadoId = null;
        for (ReservaServicio detalle : detalles) {
            if (detalle.getEmpleado() == null) {
                return null;
            }
            Integer idActual = detalle.getEmpleado().getId();
            if (empleadoId == null) {
                empleadoId = idActual;
            } else if (!empleadoId.equals(idActual)) {
                return null;
            }
        }
        return empleadoId;
    }

    private ReservaServicioDTO convertirLineaADTO(ReservaServicio linea) {
        ReservaServicioDTO dto = new ReservaServicioDTO();
        dto.setId(linea.getId());
        dto.setReservaId(linea.getReserva().getId());
        dto.setServicioId(linea.getServicio().getId());
        dto.setNombreServicio(linea.getServicio().getNombre());
        dto.setEmpleadoId(linea.getEmpleado().getId());
        dto.setNombreEmpleado(linea.getEmpleado().getNombre() + " " + linea.getEmpleado().getApellidos());
        dto.setHoraInicio(linea.getHoraInicio());
        dto.setHoraFin(linea.getHoraFin());
        dto.setPrecioUnitario(linea.getPrecioUnitario());
        dto.setCantidad(linea.getCantidad());
        dto.setEstado(linea.getEstado());
        return dto;
    }

    private ReservaServicio convertirLineaAEntidad(ReservaServicioDTO dto) {
        ReservaServicio linea = new ReservaServicio();
        linea.setHoraInicio(dto.getHoraInicio());
        linea.setHoraFin(dto.getHoraFin());
        linea.setPrecioUnitario(dto.getPrecioUnitario());
        if (dto.getCantidad() != null) {
            linea.setCantidad(dto.getCantidad());
        } else {
            linea.setCantidad(1);
        }
        linea.setEstado(EstadoReservaServicio.activo);
        return linea;
    }

}
