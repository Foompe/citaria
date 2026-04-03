package com.citaria.repository;

import com.citaria.model.Servicio;
import com.citaria.model.ServicioSkill;
import com.citaria.model.ServicioSkillId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para la entidad ServicioSkill.
 */
@Repository
public interface ServicioSkillDAO extends JpaRepository<ServicioSkill, ServicioSkillId> {

    List<ServicioSkill> findByServicio(Servicio servicio);

}