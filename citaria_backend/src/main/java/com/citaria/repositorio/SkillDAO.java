package com.citaria.repositorio;

import com.citaria.modelo.Skill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Skill.
 */
@Repository
public interface SkillDAO extends JpaRepository<Skill, Integer> {
}