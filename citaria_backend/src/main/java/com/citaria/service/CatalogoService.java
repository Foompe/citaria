package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;

import java.util.List;
import java.util.Optional;

/**
 * Contrato del servicio de gestión del catálogo.
 * Incluye gestión de servicios, categorías y skills.
 */
public interface CatalogoService {

    // Categorías
    List<CategoriaDTO> obtenerCategoriasPorOrganizacion(Integer organizacionId);
    Optional<CategoriaDTO> obtenerCategoriaPorId(Integer id);
    CategoriaDTO crearCategoria(Integer organizacionId, CategoriaDTO dto);
    Optional<CategoriaDTO> actualizarCategoria(Integer id, CategoriaDTO dto);
    boolean eliminarCategoria(Integer id);

    // Skills
    List<SkillDTO> obtenerSkillsPorOrganizacion(Integer organizacionId);
    Optional<SkillDTO> obtenerSkillPorId(Integer id);
    SkillDTO crearSkill(Integer organizacionId, SkillDTO dto);
    Optional<SkillDTO> actualizarSkill(Integer id, SkillDTO dto);
    boolean eliminarSkill(Integer id);

    // Servicios
    List<ServicioDTO> obtenerServiciosPorOrganizacion(Integer organizacionId);
    List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId);
    Optional<ServicioDTO> obtenerServicioPorId(Integer id);
    ServicioDTO crearServicio(Integer organizacionId, ServicioDTO dto);
    Optional<ServicioDTO> actualizarServicio(Integer id, ServicioDTO dto);
    boolean eliminarServicio(Integer id);

    // Skills de servicio
    List<ServicioSkillDTO> obtenerSkillsPorServicio(Integer servicioId);
    ServicioSkillDTO asignarSkillAServicio(Integer servicioId, Integer skillId);
    boolean eliminarSkillDeServicio(Integer servicioId, Integer skillId);
}