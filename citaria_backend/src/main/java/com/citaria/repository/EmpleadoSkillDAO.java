package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.EmpleadoSkill;
import com.citaria.model.EmpleadoSkillId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad EmpleadoSkill.
 */
@Repository
public interface EmpleadoSkillDAO extends JpaRepository<EmpleadoSkill, EmpleadoSkillId> {

    List<EmpleadoSkill> findByEmpleado(Empleado empleado);

}