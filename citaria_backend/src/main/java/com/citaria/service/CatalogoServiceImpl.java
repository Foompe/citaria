package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.*;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión del catálogo.
 */
@Service
public class CatalogoServiceImpl implements CatalogoService {

    private final CategoriaDAO categoriaDAO;
    private final SkillDAO skillDAO;
    private final ServicioDAO servicioDAO;
    private final ServicioSkillDAO servicioSkillDAO;
    private final ContextoSeguridad contextoSeguridad;
    private final ImagenService imagenService;

    @Autowired
    public CatalogoServiceImpl(CategoriaDAO categoriaDAO,
                               SkillDAO skillDAO,
                               ServicioDAO servicioDAO,
                               ServicioSkillDAO servicioSkillDAO,
                               ContextoSeguridad contextoSeguridad,
                               ImagenService imagenService) {
        this.categoriaDAO = categoriaDAO;
        this.skillDAO = skillDAO;
        this.servicioDAO = servicioDAO;
        this.servicioSkillDAO = servicioSkillDAO;
        this.contextoSeguridad = contextoSeguridad;
        this.imagenService = imagenService;
    }

    // CATEGORÍAS

    @Override
    @Transactional(readOnly = true)
    public List<CategoriaDTO> obtenerCategorias() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
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
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Categoria> categoriaOptional = categoriaDAO.findById(id);
        if (categoriaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Categoría con id " + id + " no encontrada");
        }
        Categoria categoria = categoriaOptional.get();
        verificarPertenenciaCategoria(categoria, organizacion);
        return convertirCategoriaADTO(categoria);
    }

    @Override
    @Transactional
    public CategoriaDTO crearCategoria(CategoriaDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Categoria categoria = convertirCategoriaAEntidad(dto);
        categoria.setOrganizacion(organizacion);
        return convertirCategoriaADTO(categoriaDAO.save(categoria));
    }

    @Override
    @Transactional
    public CategoriaDTO actualizarCategoria(Integer id, CategoriaDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Categoria> categoriaOptional = categoriaDAO.findById(id);
        if (categoriaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Categoría con id " + id + " no encontrada");
        }
        Categoria categoria = categoriaOptional.get();
        verificarPertenenciaCategoria(categoria, organizacion);
        categoria.setNombre(dto.getNombre());
        return convertirCategoriaADTO(categoriaDAO.save(categoria));
    }

    @Override
    @Transactional
    public void desactivarCategoria(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Categoria> categoriaOptional = categoriaDAO.findById(id);
        if (categoriaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Categoría con id " + id + " no encontrada");
        }
        Categoria categoria = categoriaOptional.get();
        verificarPertenenciaCategoria(categoria, organizacion);
        categoria.setActivo(false);
        categoriaDAO.save(categoria);
    }

    // SKILLS

    @Override
    @Transactional(readOnly = true)
    public List<SkillDTO> obtenerSkills() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
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
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Skill> skillOptional = skillDAO.findById(id);
        if (skillOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Skill con id " + id + " no encontrada");
        }
        Skill skill = skillOptional.get();
        verificarPertenenciaSkill(skill, organizacion);
        return convertirSkillADTO(skill);
    }

    @Override
    @Transactional
    public SkillDTO crearSkill(SkillDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Skill skill = convertirSkillAEntidad(dto);
        skill.setOrganizacion(organizacion);
        return convertirSkillADTO(skillDAO.save(skill));
    }

    @Override
    @Transactional
    public SkillDTO actualizarSkill(Integer id, SkillDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Skill> skillOptional = skillDAO.findById(id);
        if (skillOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Skill con id " + id + " no encontrada");
        }
        Skill skill = skillOptional.get();
        verificarPertenenciaSkill(skill, organizacion);
        skill.setNombre(dto.getNombre());
        skill.setDescripcion(dto.getDescripcion());
        return convertirSkillADTO(skillDAO.save(skill));
    }

    @Override
    @Transactional
    public void desactivarSkill(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Skill> skillOptional = skillDAO.findById(id);
        if (skillOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Skill con id " + id + " no encontrada");
        }
        Skill skill = skillOptional.get();
        verificarPertenenciaSkill(skill, organizacion);
        skill.setActivo(false);
        skillDAO.save(skill);
    }

    // SERVICIOS

    @Override
    @Transactional(readOnly = true)
    public List<ServicioDTO> obtenerServicios() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Servicio> servicios = servicioDAO.findByOrganizacionConCategoria(organizacion);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        for (Servicio servicio : servicios) {
            serviciosDTO.add(convertirServicioADTO(servicio));
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Categoria> categoriaOptional = categoriaDAO.findById(categoriaId);
        if (categoriaOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Categoría con id " + categoriaId + " no encontrada");
        }
        Categoria categoria = categoriaOptional.get();
        verificarPertenenciaCategoria(categoria, organizacion);
        List<Servicio> servicios = servicioDAO.findByCategoriaConCategoria(categoria);
        List<ServicioDTO> serviciosDTO = new ArrayList<>();
        for (Servicio servicio : servicios) {
            serviciosDTO.add(convertirServicioADTO(servicio));
        }
        return serviciosDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public ServicioDTO obtenerServicioPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(id);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + id + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        return convertirServicioADTO(servicio);
    }

    @Override
    @Transactional
    public ServicioDTO crearServicio(ServicioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Servicio servicio = convertirServicioAEntidad(dto);
        servicio.setOrganizacion(organizacion);
        if (dto.getCategoriaId() != null) {
            Optional<Categoria> categoriaOptional = categoriaDAO.findById(dto.getCategoriaId());
            if (categoriaOptional.isEmpty()) {
                throw new RecursoNoEncontradoException(
                        "Categoría con id " + dto.getCategoriaId() + " no encontrada");
            }
            Categoria categoria = categoriaOptional.get();
            verificarPertenenciaCategoria(categoria, organizacion);
            servicio.setCategoria(categoria);
        }
        return convertirServicioADTO(servicioDAO.save(servicio));
    }

    @Override
    @Transactional
    public void subirImagenServicio(Integer id, MultipartFile archivo) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(id);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + id + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        String imagenUrl = imagenService.subirImagen(archivo);
        servicio.setImagenUrl(imagenUrl);
        servicioDAO.save(servicio);
    }

    @Override
    @Transactional
    public ServicioDTO actualizarServicio(Integer id, ServicioDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(id);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + id + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        actualizarCamposServicio(servicio, dto);
        if (dto.getCategoriaId() != null) {
            Optional<Categoria> categoriaOptional = categoriaDAO.findById(dto.getCategoriaId());
            if (categoriaOptional.isEmpty()) {
                throw new RecursoNoEncontradoException(
                        "Categoría con id " + dto.getCategoriaId() + " no encontrada");
            }
            Categoria categoria = categoriaOptional.get();
            verificarPertenenciaCategoria(categoria, organizacion);
            servicio.setCategoria(categoria);
        } else {
            servicio.setCategoria(null);
        }
        return convertirServicioADTO(servicioDAO.save(servicio));
    }

    @Override
    @Transactional
    public void desactivarServicio(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(id);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + id + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        servicio.setActivo(false);
        servicioDAO.save(servicio);
    }

    // SKILLS DE SERVICIO

    @Override
    @Transactional(readOnly = true)
    public List<ServicioSkillDTO> obtenerSkillsPorServicio(Integer servicioId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
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
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        Optional<Skill> skillOptional = skillDAO.findById(skillId);
        if (skillOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Skill con id " + skillId + " no encontrada");
        }
        Skill skill = skillOptional.get();
        verificarPertenenciaSkill(skill, organizacion);
        ServicioSkill servicioSkill = new ServicioSkill(servicio, skill);
        return convertirServicioSkillADTO(servicioSkillDAO.save(servicioSkill));
    }

    @Override
    @Transactional
    public void quitarSkillDeServicio(Integer servicioId, Integer skillId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        Optional<Skill> skillOptional = skillDAO.findById(skillId);
        if (skillOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Skill con id " + skillId + " no encontrada");
        }
        Skill skill = skillOptional.get();
        verificarPertenenciaSkill(skill, organizacion);
        ServicioSkillId servicioSkillId = new ServicioSkillId(servicioId, skillId);
        if (!servicioSkillDAO.existsById(servicioSkillId)) {
            throw new RecursoNoEncontradoException(
                    "Asignación de skill " + skillId + " al servicio " + servicioId + " no encontrada");
        }
        servicioSkillDAO.deleteById(servicioSkillId);
    }

    //      MÉTODOS AUXILIARES


    // VERIFICACIÓN DE PERTENENCIA

    private void verificarPertenenciaCategoria(Categoria categoria, Organizacion organizacion) {
        if (!categoria.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Categoría con id " + categoria.getId() + " no encontrada");
        }
    }

    private void verificarPertenenciaSkill(Skill skill, Organizacion organizacion) {
        if (!skill.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Skill con id " + skill.getId() + " no encontrada");
        }
    }

    private void verificarPerenenciaServicio(Servicio servicio, Organizacion organizacion) {
        if (!servicio.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicio.getId() + " no encontrado");
        }
    }

    // CONVERSIONES

    private CategoriaDTO convertirCategoriaADTO(Categoria categoria) {
        CategoriaDTO dto = new CategoriaDTO();
        dto.setId(categoria.getId());
        dto.setOrganizacionId(categoria.getOrganizacion().getId());
        dto.setNombre(categoria.getNombre());
        dto.setActivo(categoria.getActivo());
        return dto;
    }

    private Categoria convertirCategoriaAEntidad(CategoriaDTO dto) {
        Categoria categoria = new Categoria();
        categoria.setNombre(dto.getNombre());
        if (dto.getActivo() != null) {
            categoria.setActivo(dto.getActivo());
        } else {
            categoria.setActivo(true);
        }
        return categoria;
    }

    private SkillDTO convertirSkillADTO(Skill skill) {
        SkillDTO dto = new SkillDTO();
        dto.setId(skill.getId());
        dto.setOrganizacionId(skill.getOrganizacion().getId());
        dto.setNombre(skill.getNombre());
        dto.setDescripcion(skill.getDescripcion());
        dto.setActivo(skill.getActivo());
        return dto;
    }

    private Skill convertirSkillAEntidad(SkillDTO dto) {
        Skill skill = new Skill();
        skill.setNombre(dto.getNombre());
        skill.setDescripcion(dto.getDescripcion());
        if (dto.getActivo() != null) {
            skill.setActivo(dto.getActivo());
        } else {
            skill.setActivo(true);
        }
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
        if (dto.getActivo() != null) {
            servicio.setActivo(dto.getActivo());
        } else {
            servicio.setActivo(true);
        }
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
