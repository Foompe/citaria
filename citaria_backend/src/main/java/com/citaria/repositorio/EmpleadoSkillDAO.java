package com.citaria.repositorio;

import com.citaria.modelo.EmpleadoSkill;
import com.citaria.modelo.EmpleadoSkillId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad EmpleadoSkill.
 */
@Repository
public interface EmpleadoSkillDAO extends JpaRepository<EmpleadoSkill, EmpleadoSkillId> {
}