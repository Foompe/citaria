package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoHabilidadDTO;
import com.citaria.dto.HorarioEmpleadoDTO;
import com.citaria.dto.ReservaDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de empleados.
 */
@Service
public class EmpleadoServiceImpl implements EmpleadoService {

    private final EmpleadoDAO empleadoDAO;
    private final HorarioEmpleadoDAO horarioEmpleadoDAO;
    private final EmpleadoHabilidadDAO empleadoHabilidadDAO;
    private final HabilidadDAO habilidadDAO;
    private final ReservaDAO reservaDAO;
    private final ContextoSeguridad contextoSeguridad;
    private final ImagenService imagenService;

    @Autowired
    public EmpleadoServiceImpl(EmpleadoDAO empleadoDAO,
                               HorarioEmpleadoDAO horarioEmpleadoDAO,
                               EmpleadoHabilidadDAO empleadoHabilidadDAO,
                               HabilidadDAO habilidadDAO,
                               ReservaDAO reservaDAO,
                               ContextoSeguridad contextoSeguridad,
                               ImagenService imagenService) {
        this.empleadoDAO = empleadoDAO;
        this.horarioEmpleadoDAO = horarioEmpleadoDAO;
        this.empleadoHabilidadDAO = empleadoHabilidadDAO;
        this.habilidadDAO = habilidadDAO;
        this.reservaDAO = reservaDAO;
        this.contextoSeguridad = contextoSeguridad;
        this.imagenService = imagenService;
    }

    // EMPLEADO

    @Override
    @Transactional(readOnly = true)
    public List<EmpleadoDTO> obtenerTodos() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Empleado> empleados = empleadoDAO.findByOrganizacion(organizacion);
        List<EmpleadoDTO> empleadosDTO = new ArrayList<>();
        for (Empleado empleado : empleados) {
            empleadosDTO.add(convertirEmpleadoADTO(empleado));
        }
        return empleadosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public EmpleadoDTO obtenerPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(id);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + id + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        return convertirEmpleadoADTO(empleado);
    }

    @Override
    @Transactional
    public EmpleadoDTO crear(EmpleadoDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Empleado empleado = convertirEmpleadoAEntidad(dto);
        empleado.setOrganizacion(organizacion);
        return convertirEmpleadoADTO(empleadoDAO.save(empleado));
    }

    @Override
    @Transactional
    public EmpleadoDTO actualizar(Integer id, EmpleadoDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(id);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + id + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        actualizarCamposEmpleado(empleado, dto);
        return convertirEmpleadoADTO(empleadoDAO.save(empleado));
    }

    @Override
    @Transactional
    public void subirFotoEmpleado(Integer id, MultipartFile archivo) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(id);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + id + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        String fotoUrl = imagenService.subirImagen(archivo);
        empleado.setFotoUrl(fotoUrl);
        empleadoDAO.save(empleado);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservaDTO> obtenerReservasActivas(Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);

        List<EstadoReserva> estadosActivos = new ArrayList<>();
        estadosActivos.add(EstadoReserva.pendiente);
        estadosActivos.add(EstadoReserva.confirmada);

        List<Reserva> reservas = reservaDAO.findReservasFuturasActivasPorEmpleado(
                empleado, LocalDate.now(), estadosActivos);
        List<ReservaDTO> reservasDTO = new ArrayList<>();
        for (Reserva reserva : reservas) {
            reservasDTO.add(convertirReservaADTO(reserva));
        }
        return reservasDTO;
    }

    // HORARIO EMPLEADO

    @Override
    @Transactional(readOnly = true)
    public List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        List<HorarioEmpleado> horarios = horarioEmpleadoDAO.findByEmpleado(empleado);
        List<HorarioEmpleadoDTO> horariosDTO = new ArrayList<>();
        for (HorarioEmpleado horario : horarios) {
            horariosDTO.add(convertirHorarioADTO(horario));
        }
        return horariosDTO;
    }

    @Override
    @Transactional
    public HorarioEmpleadoDTO crearHorario(Integer empleadoId, HorarioEmpleadoDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        HorarioEmpleado horario = convertirHorarioAEntidad(dto);
        horario.setEmpleado(empleado);
        return convertirHorarioADTO(horarioEmpleadoDAO.save(horario));
    }

    @Override
    @Transactional
    public HorarioEmpleadoDTO actualizarHorario(Integer empleadoId, Integer id, HorarioEmpleadoDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<HorarioEmpleado> horarioOptional = horarioEmpleadoDAO.findById(id);
        if (horarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Horario con id " + id + " no encontrado");
        }
        HorarioEmpleado horario = horarioOptional.get();
        verificarPertenencia(horario.getEmpleado(), organizacion);
        verificarHorarioPerteneceAEmpleado(horario, empleadoId);
        actualizarCamposHorarioEmpleado(horario, dto);
        return convertirHorarioADTO(horarioEmpleadoDAO.save(horario));
    }

    @Override
    @Transactional
    public void eliminarHorario(Integer empleadoId, Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<HorarioEmpleado> horarioOptional = horarioEmpleadoDAO.findById(id);
        if (horarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Horario con id " + id + " no encontrado");
        }
        HorarioEmpleado horario = horarioOptional.get();
        verificarPertenencia(horario.getEmpleado(), organizacion);
        verificarHorarioPerteneceAEmpleado(horario, empleadoId);
        horarioEmpleadoDAO.deleteById(id);
    }

    // HABILIDADES EMPLEADO

    @Override
    @Transactional(readOnly = true)
    public List<EmpleadoHabilidadDTO> obtenerHabilidadesPorEmpleado(Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        List<EmpleadoHabilidad> habilidades = empleadoHabilidadDAO.findByEmpleado(empleado);
        List<EmpleadoHabilidadDTO> habilidadesDTO = new ArrayList<>();
        for (EmpleadoHabilidad empleadoHabilidad : habilidades) {
            habilidadesDTO.add(convertirHabilidadADTO(empleadoHabilidad));
        }
        return habilidadesDTO;
    }

    @Override
    @Transactional
    public EmpleadoHabilidadDTO asignarHabilidad(Integer empleadoId, Integer habilidadId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(habilidadId);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + habilidadId + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        EmpleadoHabilidad empleadoHabilidad = new EmpleadoHabilidad(empleado, habilidad);
        return convertirHabilidadADTO(empleadoHabilidadDAO.save(empleadoHabilidad));
    }

    @Override
    @Transactional
    public void eliminarHabilidad(Integer empleadoId, Integer habilidadId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Empleado> empleadoOptional = empleadoDAO.findById(empleadoId);
        if (empleadoOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleadoId + " no encontrado");
        }
        Empleado empleado = empleadoOptional.get();
        verificarPertenencia(empleado, organizacion);
        EmpleadoHabilidadId empleadoHabilidadId = new EmpleadoHabilidadId(empleadoId, habilidadId);
        if (!empleadoHabilidadDAO.existsById(empleadoHabilidadId)) {
            throw new RecursoNoEncontradoException(
                    "Asignación de habilidad " + habilidadId + " al empleado " + empleadoId + " no encontrada");
        }
        empleadoHabilidadDAO.deleteById(empleadoHabilidadId);
    }

    // MÉTODOS AUXILIARES

    private void verificarPertenencia(Empleado empleado, Organizacion organizacion) {
        if (!empleado.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleado.getId() + " no encontrado");
        }
    }

    private void verificarPertenenciaHabilidad(Habilidad habilidad, Organizacion organizacion) {
        if (!habilidad.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Habilidad con id " + habilidad.getId() + " no encontrada");
        }
    }

    private void verificarHorarioPerteneceAEmpleado(HorarioEmpleado horario, Integer empleadoId) {
        if (!horario.getEmpleado().getId().equals(empleadoId)) {
            throw new RecursoNoEncontradoException("Horario con id " + horario.getId() + " no encontrado");
        }
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
        dto.setNotas(reserva.getNotas());
        dto.setMotivo(reserva.getMotivo());
        return dto;
    }

    // CONVERSIONES

    private EmpleadoDTO convertirEmpleadoADTO(Empleado empleado) {
        EmpleadoDTO dto = new EmpleadoDTO();
        dto.setId(empleado.getId());
        dto.setOrganizacionId(empleado.getOrganizacion().getId());
        dto.setNombre(empleado.getNombre());
        dto.setApellidos(empleado.getApellidos());
        dto.setEmail(empleado.getEmail());
        dto.setTelefono(empleado.getTelefono());
        dto.setFotoUrl(empleado.getFotoUrl());
        dto.setActivo(empleado.getActivo());
        dto.setAnonimizadoAt(empleado.getAnonimizadoAt());
        return dto;
    }

    private Empleado convertirEmpleadoAEntidad(EmpleadoDTO dto) {
        Empleado empleado = new Empleado();
        empleado.setNombre(dto.getNombre());
        empleado.setApellidos(dto.getApellidos());
        empleado.setEmail(dto.getEmail());
        empleado.setTelefono(dto.getTelefono());
        empleado.setFotoUrl(dto.getFotoUrl());
        if (dto.getActivo() != null) {
            empleado.setActivo(dto.getActivo());
        } else {
            empleado.setActivo(true);
        }
        return empleado;
    }

    private void actualizarCamposEmpleado(Empleado empleado, EmpleadoDTO dto) {
        empleado.setNombre(dto.getNombre());
        empleado.setApellidos(dto.getApellidos());
        empleado.setEmail(dto.getEmail());
        empleado.setTelefono(dto.getTelefono());
        empleado.setFotoUrl(dto.getFotoUrl());
        empleado.setActivo(dto.getActivo());
    }

    private HorarioEmpleadoDTO convertirHorarioADTO(HorarioEmpleado horario) {
        HorarioEmpleadoDTO dto = new HorarioEmpleadoDTO();
        dto.setId(horario.getId());
        dto.setEmpleadoId(horario.getEmpleado().getId());
        dto.setDiaSemana(horario.getDiaSemana());
        dto.setHoraInicio(horario.getHoraInicio());
        dto.setHoraFin(horario.getHoraFin());
        dto.setActivo(horario.getActivo());
        return dto;
    }

    private HorarioEmpleado convertirHorarioAEntidad(HorarioEmpleadoDTO dto) {
        HorarioEmpleado horario = new HorarioEmpleado();
        horario.setDiaSemana(dto.getDiaSemana());
        horario.setHoraInicio(dto.getHoraInicio());
        horario.setHoraFin(dto.getHoraFin());
        if (dto.getActivo() != null) {
            horario.setActivo(dto.getActivo());
        } else {
            horario.setActivo(true);
        }
        return horario;
    }

    private void actualizarCamposHorarioEmpleado(HorarioEmpleado horario, HorarioEmpleadoDTO dto) {
        horario.setDiaSemana(dto.getDiaSemana());
        horario.setHoraInicio(dto.getHoraInicio());
        horario.setHoraFin(dto.getHoraFin());
        horario.setActivo(dto.getActivo());
    }

    private EmpleadoHabilidadDTO convertirHabilidadADTO(EmpleadoHabilidad empleadoHabilidad) {
        EmpleadoHabilidadDTO dto = new EmpleadoHabilidadDTO();
        dto.setEmpleadoId(empleadoHabilidad.getEmpleado().getId());
        dto.setHabilidadId(empleadoHabilidad.getHabilidad().getId());
        dto.setNombreHabilidad(empleadoHabilidad.getHabilidad().getNombre());
        return dto;
    }
}
