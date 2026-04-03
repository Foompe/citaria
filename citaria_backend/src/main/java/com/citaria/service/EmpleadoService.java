package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;

import java.util.List;
import java.util.Optional;

/**
 * Contrato del servicio de gestión de empleados.
 * Incluye gestión de horarios y skills del empleado.
 */
public interface EmpleadoService {

    // Empleado
    List<EmpleadoDTO> obtenerTodos(Integer organizacionId);
    Optional<EmpleadoDTO> obtenerPorId(Integer id);
    EmpleadoDTO crear(Integer organizacionId, EmpleadoDTO dto);
    Optional<EmpleadoDTO> actualizar(Integer id, EmpleadoDTO dto);
    boolean eliminar(Integer id);

    // Horario empleado
    List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId);
    HorarioEmpleadoDTO crearHorario(Integer empleadoId, HorarioEmpleadoDTO dto);
    Optional<HorarioEmpleadoDTO> actualizarHorario(Integer id, HorarioEmpleadoDTO dto);
    boolean eliminarHorario(Integer id);

    // Skills empleado
    List<EmpleadoSkillDTO> obtenerSkillsPorEmpleado(Integer empleadoId);
    EmpleadoSkillDTO asignarSkill(Integer empleadoId, Integer skillId);
    boolean eliminarSkill(Integer empleadoId, Integer skillId);
}