package com.citaria.service;

import com.citaria.dto.EmpleadoDTO;
import com.citaria.dto.EmpleadoSkillDTO;
import com.citaria.dto.HorarioEmpleadoDTO;
import com.citaria.dto.ReservaDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * Servicio de gestión de empleados: horarios y skills.
 */
public interface EmpleadoService {

    // Empleado
    List<EmpleadoDTO> obtenerTodos();
    EmpleadoDTO obtenerPorId(Integer id);
    EmpleadoDTO crear(EmpleadoDTO dto);
    EmpleadoDTO actualizar(Integer id, EmpleadoDTO dto);
    void subirFotoEmpleado(Integer id, MultipartFile archivo);
    List<ReservaDTO> obtenerReservasActivas(Integer empleadoId);

    // Horario empleado
    List<HorarioEmpleadoDTO> obtenerHorariosPorEmpleado(Integer empleadoId);
    HorarioEmpleadoDTO crearHorario(Integer empleadoId, HorarioEmpleadoDTO dto);
    HorarioEmpleadoDTO actualizarHorario(Integer empleadoId, Integer id, HorarioEmpleadoDTO dto);
    void eliminarHorario(Integer empleadoId, Integer id);

    // Skills empleado
    List<EmpleadoSkillDTO> obtenerSkillsPorEmpleado(Integer empleadoId);
    EmpleadoSkillDTO asignarSkill(Integer empleadoId, Integer skillId);
    void eliminarSkill(Integer empleadoId, Integer skillId);

}