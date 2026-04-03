package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.HorarioEmpleado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad HorarioEmpleado.
 */
@Repository
public interface HorarioEmpleadoDAO extends JpaRepository<HorarioEmpleado, Integer> {

    List<HorarioEmpleado> findByEmpleado(Empleado empleado);

}