package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;
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
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<CategoriaDTO> categoriasDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Categoria> categorias = categoriaDAO.findByOrganizacion(organizacion.get());
            for (Categoria categoria : categorias) {
                categoriasDTO.add(convertirCategoriaADTO(categoria));
            }
        }
        return categoriasDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CategoriaDTO> obtenerCategoriaPorId(Integer id) {
        Optional<Categoria> categoria = categoriaDAO.findById(id);
        if (categoria.isPresent()) {
            return Optional.of(convertirCategoriaADTO(categoria.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public CategoriaDTO crearCategoria(Integer organizacionId, CategoriaDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Categoria categoria = convertirCategoriaAEntidad(dto);
        categoria.setOrganizacion(organizacion.get());
        return convertirCategoriaADTO(categoriaDAO.save(categoria));
    }

    @Override
    @Transactional
    public Optional<CategoriaDTO> actualizarCategoria(Integer id, CategoriaDTO dto) {
        Optional<Categoria> existente = categoriaDAO.findById(id);
        if (existente.isPresent()) {
            Categoria categoria = existente.get();
            categoria.setNombre(dto.getNombre());
            return Optional.of(convertirCategoriaADTO(categoriaDAO.save(categoria)));
        }
        return Optional.empty();
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
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<SkillDTO> skillsDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Skill> skills = skillDAO.findByOrganizacion(organizacion.get());
            for (Skill skill : skills) {
                skillsDTO.add(convertirSkillADTO(skill));
            }
        }
        return skillsDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SkillDTO> obtenerSkillPorId(Integer id) {
        Optional<Skill> skill = skillDAO.findById(id);
        if (skill.isPresent()) {
            return Optional.of(convertirSkillADTO(skill.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public SkillDTO crearSkill(Integer organizacionId, SkillDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Skill skill = convertirSkillAEntidad(dto);
        skill.setOrganizacion(organizacion.get());
        return convertirSkillADTO(skillDAO.save(skill));
    }

    @Override
    @Transactional
    public Optional<SkillDTO> actualizarSkill(Integer id, SkillDTO dto) {
        Optional<Skill> existente = skillDAO.findById(id);
        if (existente.isPresent()) {
            Skill skill = existente.get();
            skill.setNombre(dto.getNombre());
            skill.setDescripcion(dto.getDescripcion());
            return Optional.of(convertirSkillADTO(skillDAO.save(skill)));
        }
        return Optional.empty();
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
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<Servicio> servicios = servicioDAO.findByOrganizacion(organizacion.get());
            for (Servicio servicio : servicios) {
                serviciosDTO.add(convertirServicioADTO(servicio));
            }
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId) {
        Optional<Categoria> categoria = categoriaDAO.findById(categoriaId);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        if (categoria.isPresent()) {
            List<Servicio> servicios = servicioDAO.findByCategoria(categoria.get());
            for (Servicio servicio : servicios) {
                serviciosDTO.add(convertirServicioADTO(servicio));
            }
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ServicioDTO> obtenerServicioPorId(Integer id) {
        Optional<Servicio> servicio = servicioDAO.findById(id);
        if (servicio.isPresent()) {
            return Optional.of(convertirServicioADTO(servicio.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public ServicioDTO crearServicio(Integer organizacionId, ServicioDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        Servicio servicio = convertirServicioAEntidad(dto);
        servicio.setOrganizacion(organizacion.get());
        if (dto.getCategoriaId() != null) {
            Optional<Categoria> categoria = categoriaDAO.findById(dto.getCategoriaId());
            categoria.ifPresent(servicio::setCategoria);
        }
        return convertirServicioADTO(servicioDAO.save(servicio));
    }

    @Override
    @Transactional
    public Optional<ServicioDTO> actualizarServicio(Integer id, ServicioDTO dto) {
        Optional<Servicio> existente = servicioDAO.findById(id);
        if (existente.isPresent()) {
            Servicio servicio = existente.get();
            servicio.setNombre(dto.getNombre());
            servicio.setDescripcion(dto.getDescripcion());
            servicio.setImagenUrl(dto.getImagenUrl());
            servicio.setPrecio(dto.getPrecio());
            servicio.setDuracionMinutos(dto.getDuracionMinutos());
            servicio.setActivo(dto.getActivo());
            if (dto.getCategoriaId() != null) {
                Optional<Categoria> categoria = categoriaDAO.findById(dto.getCategoriaId());
                categoria.ifPresent(servicio::setCategoria);
            } else {
                servicio.setCategoria(null);
            }
            return Optional.of(convertirServicioADTO(servicioDAO.save(servicio)));
        }
        return Optional.empty();
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
        Optional<Servicio> servicio = servicioDAO.findById(servicioId);
        List<ServicioSkillDTO> skillsDTO = new ArrayList<>();
        if (servicio.isPresent()) {
            List<ServicioSkill> skills = servicioSkillDAO.findByServicio(servicio.get());
            for (ServicioSkill servicioSkill : skills) {
                skillsDTO.add(convertirServicioSkillADTO(servicioSkill));
            }
        }
        return skillsDTO;
    }

    @Override
    @Transactional
    public ServicioSkillDTO asignarSkillAServicio(Integer servicioId, Integer skillId) {
        Optional<Servicio> servicio = servicioDAO.findById(servicioId);
        Optional<Skill> skill = skillDAO.findById(skillId);
        ServicioSkill servicioSkill = new ServicioSkill(servicio.get(), skill.get());
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

    private ServicioSkillDTO convertirServicioSkillADTO(ServicioSkill servicioSkill) {
        ServicioSkillDTO dto = new ServicioSkillDTO();
        dto.setServicioId(servicioSkill.getServicio().getId());
        dto.setSkillId(servicioSkill.getSkill().getId());
        dto.setNombreSkill(servicioSkill.getSkill().getNombre());
        return dto;
    }
}