package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * Implementación del servicio de gestión de empleados.
 * Incluye gestión de horarios y skills del empleado.
 * La organización se resuelve automáticamente desde el contexto de seguridad,
 * garantizando que un usuario solo puede acceder a datos de su organización.
 */
@Service
public class EmpleadoServiceImpl implements EmpleadoService {

    private final EmpleadoDAO empleadoDAO;
    private final HorarioEmpleadoDAO horarioEmpleadoDAO;
    private final EmpleadoSkillDAO empleadoSkillDAO;
    private final SkillDAO skillDAO;
    private final ContextoSeguridad contextoSeguridad;

    public EmpleadoServiceImpl(EmpleadoDAO empleadoDAO,
                               HorarioEmpleadoDAO horarioEmpleadoDAO,
                               EmpleadoSkillDAO empleadoSkillDAO,
                               SkillDAO skillDAO,
                               ContextoSeguridad contextoSeguridad) {
        this.empleadoDAO = empleadoDAO;
        this.horarioEmpleadoDAO = horarioEmpleadoDAO;
        this.empleadoSkillDAO = empleadoSkillDAO;
        this.skillDAO = skillDAO;
        this.contextoSeguridad = contextoSeguridad;
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
        Empleado empleado = empleadoDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + id + " no encontrado"));
        verificarTenencia(empleado, organizacion);
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
        Empleado empleado = empleadoDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + id + " no encontrado"));
        verificarTenencia(empleado, organizacion);
        actualizarCamposEmpleado(empleado, dto);
        return convertirEmpleadoADTO(empleadoDAO.save(empleado));
    }

    // HORARIO EMPLEADO

    @Override
    @Transactional(readOnly = true)
    public List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Empleado empleado = empleadoDAO.findById(empleadoId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + empleadoId + " no encontrado"));
        verificarTenencia(empleado, organizacion);
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
        Empleado empleado = empleadoDAO.findById(empleadoId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + empleadoId + " no encontrado"));
        verificarTenencia(empleado, organizacion);
        HorarioEmpleado horario = convertirHorarioAEntidad(dto);
        horario.setEmpleado(empleado);
        return convertirHorarioADTO(horarioEmpleadoDAO.save(horario));
    }

    @Override
    @Transactional
    public HorarioEmpleadoDTO actualizarHorario(Integer id, HorarioEmpleadoDTO dto) {
        HorarioEmpleado horario = horarioEmpleadoDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Horario con id " + id + " no encontrado"));
        actualizarCamposHorarioEmpleado(horario, dto);
        return convertirHorarioADTO(horarioEmpleadoDAO.save(horario));
    }

    @Override
    @Transactional
    public boolean eliminarHorario(Integer id) {
        if (horarioEmpleadoDAO.existsById(id)) {
            horarioEmpleadoDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // SKILLS EMPLEADO

    @Override
    @Transactional(readOnly = true)
    public List<EmpleadoSkillDTO> obtenerSkillsPorEmpleado(Integer empleadoId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Empleado empleado = empleadoDAO.findById(empleadoId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + empleadoId + " no encontrado"));
        verificarTenencia(empleado, organizacion);
        List<EmpleadoSkill> skills = empleadoSkillDAO.findByEmpleado(empleado);
        List<EmpleadoSkillDTO> skillsDTO = new ArrayList<>();
        for (EmpleadoSkill empleadoSkill : skills) {
            skillsDTO.add(convertirSkillADTO(empleadoSkill));
        }
        return skillsDTO;
    }

    @Override
    @Transactional
    public EmpleadoSkillDTO asignarSkill(Integer empleadoId, Integer skillId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Empleado empleado = empleadoDAO.findById(empleadoId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Empleado con id " + empleadoId + " no encontrado"));
        verificarTenencia(empleado, organizacion);
        Skill skill = skillDAO.findById(skillId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Skill con id " + skillId + " no encontrada"));
        EmpleadoSkill empleadoSkill = new EmpleadoSkill(empleado, skill);
        return convertirSkillADTO(empleadoSkillDAO.save(empleadoSkill));
    }

    @Override
    @Transactional
    public boolean eliminarSkill(Integer empleadoId, Integer skillId) {
        EmpleadoSkillId empleadoSkillId = new EmpleadoSkillId(empleadoId, skillId);
        if (empleadoSkillDAO.existsById(empleadoSkillId)) {
            empleadoSkillDAO.deleteById(empleadoSkillId);
            return true;
        }
        return false;
    }

    // MÉTODOS PRIVADOS

    private void verificarTenencia(Empleado empleado, Organizacion organizacion) {
        if (!empleado.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Empleado con id " + empleado.getId() + " no encontrado");
        }
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
        empleado.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
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
        horario.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
        return horario;
    }

    private void actualizarCamposHorarioEmpleado(HorarioEmpleado horario, HorarioEmpleadoDTO dto) {
        horario.setDiaSemana(dto.getDiaSemana());
        horario.setHoraInicio(dto.getHoraInicio());
        horario.setHoraFin(dto.getHoraFin());
        horario.setActivo(dto.getActivo());
    }

    private EmpleadoSkillDTO convertirSkillADTO(EmpleadoSkill empleadoSkill) {
        EmpleadoSkillDTO dto = new EmpleadoSkillDTO();
        dto.setEmpleadoId(empleadoSkill.getEmpleado().getId());
        dto.setSkillId(empleadoSkill.getSkill().getId());
        dto.setNombreSkill(empleadoSkill.getSkill().getNombre());
        return dto;
    }
}