package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;

import java.util.List;

/**
 * Contrato del servicio de gestión del catálogo.
 * Incluye gestión de servicios, categorías y skills.
 * La organización se resuelve automáticamente desde el contexto de seguridad.
 */
public interface CatalogoService {

    // Categorías
    List<CategoriaDTO> obtenerCategorias();
    CategoriaDTO obtenerCategoriaPorId(Integer id);
    CategoriaDTO crearCategoria(CategoriaDTO dto);
    CategoriaDTO actualizarCategoria(Integer id, CategoriaDTO dto);

    /**
     * Desactiva una categoría de forma lógica (activo = false).
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     */
    void eliminarCategoria(Integer id);

    // Skills
    List<SkillDTO> obtenerSkills();
    SkillDTO obtenerSkillPorId(Integer id);
    SkillDTO crearSkill(SkillDTO dto);
    SkillDTO actualizarSkill(Integer id, SkillDTO dto);

    /**
     * Desactiva una skill de forma lógica (activo = false).
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     */
    void eliminarSkill(Integer id);

    // Servicios
    List<ServicioDTO> obtenerServicios();
    List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId);
    ServicioDTO obtenerServicioPorId(Integer id);
    ServicioDTO crearServicio(ServicioDTO dto);
    ServicioDTO actualizarServicio(Integer id, ServicioDTO dto);

    /**
     * Desactiva un servicio de forma lógica (activo = false).
     * Lanza {@link com.citaria.exception.RecursoNoEncontradoException} si el id no existe.
     */
    void eliminarServicio(Integer id);

    // Skills de servicio
    List<ServicioSkillDTO> obtenerSkillsPorServicio(Integer servicioId);
    ServicioSkillDTO asignarSkillAServicio(Integer servicioId, Integer skillId);
    boolean eliminarSkillDeServicio(Integer servicioId, Integer skillId);
}