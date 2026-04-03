package com.citaria.repositorio;

import com.citaria.modelo.ServicioSkill;
import com.citaria.modelo.ServicioSkillId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad ServicioSkill.
 */
@Repository
public interface ServicioSkillDAO extends JpaRepository<ServicioSkill, ServicioSkillId> {
}