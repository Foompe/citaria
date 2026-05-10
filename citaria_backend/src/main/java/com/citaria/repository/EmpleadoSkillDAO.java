package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.EmpleadoSkill;
import com.citaria.model.EmpleadoSkillId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para EmpleadoSkill.
 */
@Repository
public interface EmpleadoSkillDAO extends JpaRepository<EmpleadoSkill, EmpleadoSkillId> {

    List<EmpleadoSkill> findByEmpleado(Empleado empleado);

    /**
     * Compara de una lista las skills y devuelve el número de las que coinciden, si es el mismo es que puede
     * dar ese servicio.
     */
    @Query("SELECT COUNT(es) FROM EmpleadoSkill es WHERE es.empleado = :empleado AND es.skill.id IN :skillIds")
    long contarSkillsQueCoinciden(@Param("empleado") Empleado empleado, @Param("skillIds") List<Integer> skillIds);
}