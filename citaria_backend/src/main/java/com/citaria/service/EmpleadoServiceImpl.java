package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;
import com.citaria.model.*;
import com.citaria.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de empleados.
 * Incluye gestión de horarios y skills del empleado.
 */
@Service
public class EmpleadoServiceImpl implements EmpleadoService {

    private EmpleadoDAO empleadoDAO;
    private HorarioEmpleadoDAO horarioEmpleadoDAO;
    private EmpleadoSkillDAO empleadoSkillDAO;
    private SkillDAO skillDAO;
    private OrganizacionDAO organizacionDAO;

    @Autowired
    public EmpleadoServiceImpl(EmpleadoDAO empleadoDAO,
                               HorarioEmpleadoDAO horarioEmpleadoDAO,
                               EmpleadoSkillDAO empleadoSkillDAO,
                               SkillDAO skillDAO,
                               OrganizacionDAO organizacionDAO) {
        this.empleadoDAO = empleadoDAO;
        this.horarioEmpleadoDAO = horarioEmpleadoDAO;
        this.empleadoSkillDAO = empleadoSkillDAO;
        this.skillDAO = skillDAO;
        this.organizacionDAO = organizacionDAO;
    }

    // ===== EMPLEADO =====

    @Override
    @Transactional(readOnly = true)
    public List<EmpleadoDTO> obtenerTodos(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<EmpleadoDTO> empleadosDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Empleado> empleados = empleadoDAO.findByOrganizacion(organizacion.get());
            for (Empleado empleado : empleados) {
                empleadosDTO.add(convertirEmpleadoADTO(empleado));
            }
        }
        return empleadosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<EmpleadoDTO> obtenerPorId(Integer id) {
        Optional<Empleado> empleado = empleadoDAO.findById(id);
        if (empleado.isPresent()) {
            return Optional.of(convertirEmpleadoADTO(empleado.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public EmpleadoDTO crear(Integer organizacionId, EmpleadoDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Empleado empleado = convertirEmpleadoAEntidad(dto);
        empleado.setOrganizacion(organizacion.get());
        return convertirEmpleadoADTO(empleadoDAO.save(empleado));
    }

    @Override
    @Transactional
    public Optional<EmpleadoDTO> actualizar(Integer id, EmpleadoDTO dto) {
        Optional<Empleado> existente = empleadoDAO.findById(id);
        if (existente.isPresent()) {
            Empleado empleado = existente.get();
            empleado.setNombre(dto.getNombre());
            empleado.setApellidos(dto.getApellidos());
            empleado.setEmail(dto.getEmail());
            empleado.setTelefono(dto.getTelefono());
            empleado.setFotoUrl(dto.getFotoUrl());
            empleado.setActivo(dto.getActivo());
            return Optional.of(convertirEmpleadoADTO(empleadoDAO.save(empleado)));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public boolean eliminar(Integer id) {
        if (empleadoDAO.existsById(id)) {
            empleadoDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== HORARIO EMPLEADO =====

    @Override
    @Transactional(readOnly = true)
    public List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId) {
        Optional<Empleado> empleado = empleadoDAO.findById(empleadoId);
        List<HorarioEmpleadoDTO> horariosDTO = new ArrayList<>();
        if (empleado.isPresent()) {
            List<HorarioEmpleado> horarios = horarioEmpleadoDAO.findByEmpleado(empleado.get());
            for (HorarioEmpleado horario : horarios) {
                horariosDTO.add(convertirHorarioADTO(horario));
            }
        }
        return horariosDTO;
    }

    @Override
    @Transactional
    public HorarioEmpleadoDTO crearHorario(Integer empleadoId, HorarioEmpleadoDTO dto) {
        Optional<Empleado> empleado = empleadoDAO.findById(empleadoId);
        HorarioEmpleado horario = convertirHorarioAEntidad(dto);
        horario.setEmpleado(empleado.get());
        return convertirHorarioADTO(horarioEmpleadoDAO.save(horario));
    }

    @Override
    @Transactional
    public Optional<HorarioEmpleadoDTO> actualizarHorario(Integer id, HorarioEmpleadoDTO dto) {
        Optional<HorarioEmpleado> existente = horarioEmpleadoDAO.findById(id);
        if (existente.isPresent()) {
            HorarioEmpleado horario = existente.get();
            horario.setDiaSemana(dto.getDiaSemana());
            horario.setHoraInicio(dto.getHoraInicio());
            horario.setHoraFin(dto.getHoraFin());
            horario.setActivo(dto.getActivo());
            return Optional.of(convertirHorarioADTO(horarioEmpleadoDAO.save(horario)));
        }
        return Optional.empty();
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

    // ===== SKILLS EMPLEADO =====

    @Override
    @Transactional(readOnly = true)
    public List<EmpleadoSkillDTO> obtenerSkillsPorEmpleado(Integer empleadoId) {
        Optional<Empleado> empleado = empleadoDAO.findById(empleadoId);
        List<EmpleadoSkillDTO> skillsDTO = new ArrayList<>();
        if (empleado.isPresent()) {
            List<EmpleadoSkill> skills = empleadoSkillDAO.findByEmpleado(empleado.get());
            for (EmpleadoSkill empleadoSkill : skills) {
                skillsDTO.add(convertirSkillADTO(empleadoSkill));
            }
        }
        return skillsDTO;
    }

    @Override
    @Transactional
    public EmpleadoSkillDTO asignarSkill(Integer empleadoId, Integer skillId) {
        Optional<Empleado> empleado = empleadoDAO.findById(empleadoId);
        Optional<Skill> skill = skillDAO.findById(skillId);
        EmpleadoSkill empleadoSkill = new EmpleadoSkill(empleado.get(), skill.get());
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

    // ===== CONVERSIONES =====

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

    private EmpleadoSkillDTO convertirSkillADTO(EmpleadoSkill empleadoSkill) {
        EmpleadoSkillDTO dto = new EmpleadoSkillDTO();
        dto.setEmpleadoId(empleadoSkill.getEmpleado().getId());
        dto.setSkillId(empleadoSkill.getSkill().getId());
        dto.setNombreSkill(empleadoSkill.getSkill().getNombre());
        return dto;
    }
}