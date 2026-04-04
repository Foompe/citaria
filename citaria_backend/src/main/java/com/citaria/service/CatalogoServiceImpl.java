package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión del catálogo.
 * Incluye gestión de servicios, categorías y skills.
 */
@Service
public class CatalogoServiceImpl implements CatalogoService {

    private CategoriaDAO categoriaDAO;
    private SkillDAO skillDAO;
    private ServicioDAO servicioDAO;
    private ServicioSkillDAO servicioSkillDAO;
    private OrganizacionDAO organizacionDAO;

    @Autowired
    public CatalogoServiceImpl(CategoriaDAO categoriaDAO,
                               SkillDAO skillDAO,
                               ServicioDAO servicioDAO,
                               ServicioSkillDAO servicioSkillDAO,
                               OrganizacionDAO organizacionDAO) {
        this.categoriaDAO = categoriaDAO;
        this.skillDAO = skillDAO;
        this.servicioDAO = servicioDAO;
        this.servicioSkillDAO = servicioSkillDAO;
        this.organizacionDAO = organizacionDAO;
    }

    // ===== CATEGORÍAS =====

    @Override
    @Transactional(readOnly = true)
    public List<CategoriaDTO> obtenerCategoriasPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<Categoria> categorias = categoriaDAO.findByOrganizacion(organizacion);
        List<CategoriaDTO> categoriasDTO = new ArrayList<>();
        for (Categoria categoria : categorias) {
            categoriasDTO.add(convertirCategoriaADTO(categoria));
        }
        return categoriasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public CategoriaDTO obtenerCategoriaPorId(Integer id) {
        Categoria categoria = categoriaDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Categoría con id " + id + " no encontrada"));
        return convertirCategoriaADTO(categoria);
    }

    @Override
    @Transactional
    public CategoriaDTO crearCategoria(Integer organizacionId, CategoriaDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        Categoria categoria = convertirCategoriaAEntidad(dto);
        categoria.setOrganizacion(organizacion);
        return convertirCategoriaADTO(categoriaDAO.save(categoria));
    }

    @Override
    @Transactional
    public CategoriaDTO actualizarCategoria(Integer id, CategoriaDTO dto) {
        Categoria categoria = categoriaDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Categoría con id " + id + " no encontrada"));
        categoria.setNombre(dto.getNombre());
        return convertirCategoriaADTO(categoriaDAO.save(categoria));
    }

    @Override
    @Transactional
    public boolean eliminarCategoria(Integer id) {
        if (categoriaDAO.existsById(id)) {
            categoriaDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== SKILLS =====

    @Override
    @Transactional(readOnly = true)
    public List<SkillDTO> obtenerSkillsPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<Skill> skills = skillDAO.findByOrganizacion(organizacion);
        List<SkillDTO> skillsDTO = new ArrayList<>();
        for (Skill skill : skills) {
            skillsDTO.add(convertirSkillADTO(skill));
        }
        return skillsDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public SkillDTO obtenerSkillPorId(Integer id) {
        Skill skill = skillDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Skill con id " + id + " no encontrada"));
        return convertirSkillADTO(skill);
    }

    @Override
    @Transactional
    public SkillDTO crearSkill(Integer organizacionId, SkillDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        Skill skill = convertirSkillAEntidad(dto);
        skill.setOrganizacion(organizacion);
        return convertirSkillADTO(skillDAO.save(skill));
    }

    @Override
    @Transactional
    public SkillDTO actualizarSkill(Integer id, SkillDTO dto) {
        Skill skill = skillDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Skill con id " + id + " no encontrada"));
        skill.setNombre(dto.getNombre());
        skill.setDescripcion(dto.getDescripcion());
        return convertirSkillADTO(skillDAO.save(skill));
    }

    @Override
    @Transactional
    public boolean eliminarSkill(Integer id) {
        if (skillDAO.existsById(id)) {
            skillDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== SERVICIOS =====

    @Override
    @Transactional(readOnly = true)
    public List<ServicioDTO> obtenerServiciosPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<Servicio> servicios = servicioDAO.findByOrganizacion(organizacion);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        for (Servicio servicio : servicios) {
            serviciosDTO.add(convertirServicioADTO(servicio));
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId) {
        Categoria categoria = categoriaDAO.findById(categoriaId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Categoría con id " + categoriaId + " no encontrada"));
        List<Servicio> servicios = servicioDAO.findByCategoria(categoria);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        for (Servicio servicio : servicios) {
            serviciosDTO.add(convertirServicioADTO(servicio));
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public ServicioDTO obtenerServicioPorId(Integer id) {
        Servicio servicio = servicioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Servicio con id " + id + " no encontrado"));
        return convertirServicioADTO(servicio);
    }

    @Override
    @Transactional
    public ServicioDTO crearServicio(Integer organizacionId, ServicioDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        Servicio servicio = convertirServicioAEntidad(dto);
        servicio.setOrganizacion(organizacion);
        if (dto.getCategoriaId() != null) {
            Optional<Categoria> categoria = categoriaDAO.findById(dto.getCategoriaId());
            categoria.ifPresent(servicio::setCategoria);
        }
        return convertirServicioADTO(servicioDAO.save(servicio));
    }

    @Override
    @Transactional
    public ServicioDTO actualizarServicio(Integer id, ServicioDTO dto) {
        Servicio servicio = servicioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Servicio con id " + id + " no encontrado"));
        actualizarCamposServicio(servicio, dto);
        if (dto.getCategoriaId() != null) {
            Optional<Categoria> categoria = categoriaDAO.findById(dto.getCategoriaId());
            categoria.ifPresent(servicio::setCategoria);
        } else {
            servicio.setCategoria(null);
        }
        return convertirServicioADTO(servicioDAO.save(servicio));
    }

    @Override
    @Transactional
    public boolean eliminarServicio(Integer id) {
        if (servicioDAO.existsById(id)) {
            servicioDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // ===== SKILLS DE SERVICIO =====

    @Override
    @Transactional(readOnly = true)
    public List<ServicioSkillDTO> obtenerSkillsPorServicio(Integer servicioId) {
        Servicio servicio = servicioDAO.findById(servicioId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Servicio con id " + servicioId + " no encontrado"));
        List<ServicioSkill> skills = servicioSkillDAO.findByServicio(servicio);
        List<ServicioSkillDTO> skillsDTO = new ArrayList<>();
        for (ServicioSkill servicioSkill : skills) {
            skillsDTO.add(convertirServicioSkillADTO(servicioSkill));
        }
        return skillsDTO;
    }

    @Override
    @Transactional
    public ServicioSkillDTO asignarSkillAServicio(Integer servicioId, Integer skillId) {
        Servicio servicio = servicioDAO.findById(servicioId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Servicio con id " + servicioId + " no encontrado"));
        Skill skill = skillDAO.findById(skillId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Skill con id " + skillId + " no encontrada"));
        ServicioSkill servicioSkill = new ServicioSkill(servicio, skill);
        return convertirServicioSkillADTO(servicioSkillDAO.save(servicioSkill));
    }

    @Override
    @Transactional
    public boolean eliminarSkillDeServicio(Integer servicioId, Integer skillId) {
        ServicioSkillId servicioSkillId = new ServicioSkillId(servicioId, skillId);
        if (servicioSkillDAO.existsById(servicioSkillId)) {
            servicioSkillDAO.deleteById(servicioSkillId);
            return true;
        }
        return false;
    }

    // ===== CONVERSIONES =====

    private CategoriaDTO convertirCategoriaADTO(Categoria categoria) {
        CategoriaDTO dto = new CategoriaDTO();
        dto.setId(categoria.getId());
        dto.setOrganizacionId(categoria.getOrganizacion().getId());
        dto.setNombre(categoria.getNombre());
        return dto;
    }

    private Categoria convertirCategoriaAEntidad(CategoriaDTO dto) {
        Categoria categoria = new Categoria();
        categoria.setNombre(dto.getNombre());
        return categoria;
    }

    private SkillDTO convertirSkillADTO(Skill skill) {
        SkillDTO dto = new SkillDTO();
        dto.setId(skill.getId());
        dto.setOrganizacionId(skill.getOrganizacion().getId());
        dto.setNombre(skill.getNombre());
        dto.setDescripcion(skill.getDescripcion());
        return dto;
    }

    private Skill convertirSkillAEntidad(SkillDTO dto) {
        Skill skill = new Skill();
        skill.setNombre(dto.getNombre());
        skill.setDescripcion(dto.getDescripcion());
        return skill;
    }

    private ServicioDTO convertirServicioADTO(Servicio servicio) {
        ServicioDTO dto = new ServicioDTO();
        dto.setId(servicio.getId());
        dto.setOrganizacionId(servicio.getOrganizacion().getId());
        dto.setNombre(servicio.getNombre());
        dto.setDescripcion(servicio.getDescripcion());
        dto.setImagenUrl(servicio.getImagenUrl());
        dto.setPrecio(servicio.getPrecio());
        dto.setDuracionMinutos(servicio.getDuracionMinutos());
        dto.setActivo(servicio.getActivo());
        if (servicio.getCategoria() != null) {
            dto.setCategoriaId(servicio.getCategoria().getId());
            dto.setNombreCategoria(servicio.getCategoria().getNombre());
        }
        return dto;
    }

    private Servicio convertirServicioAEntidad(ServicioDTO dto) {
        Servicio servicio = new Servicio();
        servicio.setNombre(dto.getNombre());
        servicio.setDescripcion(dto.getDescripcion());
        servicio.setImagenUrl(dto.getImagenUrl());
        servicio.setPrecio(dto.getPrecio());
        servicio.setDuracionMinutos(dto.getDuracionMinutos());
        servicio.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
        return servicio;
    }

    private void actualizarCamposServicio(Servicio servicio, ServicioDTO dto) {
        servicio.setNombre(dto.getNombre());
        servicio.setDescripcion(dto.getDescripcion());
        servicio.setImagenUrl(dto.getImagenUrl());
        servicio.setPrecio(dto.getPrecio());
        servicio.setDuracionMinutos(dto.getDuracionMinutos());
        servicio.setActivo(dto.getActivo());
    }

    private ServicioSkillDTO convertirServicioSkillADTO(ServicioSkill servicioSkill) {
        ServicioSkillDTO dto = new ServicioSkillDTO();
        dto.setServicioId(servicioSkill.getServicio().getId());
        dto.setSkillId(servicioSkill.getSkill().getId());
        dto.setNombreSkill(servicioSkill.getSkill().getNombre());
        return dto;
    }
}