package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;

import java.util.List;

/**
 * Contrato del servicio de gestión de empleados.
 * Incluye gestión de horarios y skills del empleado.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 * La eliminación de un empleado se gestiona exclusivamente a través de
 * {@link UsuarioService#eliminar(Integer)}, que garantiza la anonimización
 * de datos personales en una única transacción.
 */
public interface EmpleadoService {

    // Empleado
    List<EmpleadoDTO> obtenerTodos();
    EmpleadoDTO obtenerPorId(Integer id);
    EmpleadoDTO crear(EmpleadoDTO dto);
    EmpleadoDTO actualizar(Integer id, EmpleadoDTO dto);

    // Horario empleado
    List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId);
    HorarioEmpleadoDTO crearHorario(Integer empleadoId, HorarioEmpleadoDTO dto);
    HorarioEmpleadoDTO actualizarHorario(Integer id, HorarioEmpleadoDTO dto);
    boolean eliminarHorario(Integer id);

    // Skills empleado
    List<EmpleadoSkillDTO> obtenerSkillsPorEmpleado(Integer empleadoId);
    EmpleadoSkillDTO asignarSkill(Integer empleadoId, Integer skillId);
    boolean eliminarSkill(Integer empleadoId, Integer skillId);
}