package com.citaria.repository;

import com.citaria.model.Organizacion;
import com.citaria.model.Skill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para Skill.
 */
@Repository
public interface SkillDAO extends JpaRepository<Skill, Integer> {

    List<Skill> findByOrganizacion(Organizacion organizacion);

}