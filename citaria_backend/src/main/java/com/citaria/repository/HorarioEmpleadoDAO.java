package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.HorarioEmpleado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para HorarioEmpleado.
 */
@Repository
public interface HorarioEmpleadoDAO extends JpaRepository<HorarioEmpleado, Integer> {

    List<HorarioEmpleado> findByEmpleado(Empleado empleado);
    List<HorarioEmpleado> findByEmpleadoIn(List<Empleado> empleados);
    Optional<HorarioEmpleado> findByEmpleadoAndDiaSemanaAndActivo(Empleado empleado, Integer diaSemana, Boolean activo);

}