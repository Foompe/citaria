package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * Servicio de gestión de servicios, categorías y skills.
 */
public interface CatalogoService {

    // Categorías
    List<CategoriaDTO> obtenerCategorias();
    CategoriaDTO obtenerCategoriaPorId(Integer id);
    CategoriaDTO crearCategoria(CategoriaDTO dto);
    CategoriaDTO actualizarCategoria(Integer id, CategoriaDTO dto);
    void desactivarCategoria(Integer id);

    // Skills
    List<SkillDTO> obtenerSkills();
    SkillDTO obtenerSkillPorId(Integer id);
    SkillDTO crearSkill(SkillDTO dto);
    SkillDTO actualizarSkill(Integer id, SkillDTO dto);
    void desactivarSkill(Integer id);

    // Servicios
    List<ServicioDTO> obtenerServicios();
    List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId);
    ServicioDTO obtenerServicioPorId(Integer id);
    ServicioDTO crearServicio(ServicioDTO dto);
    ServicioDTO actualizarServicio(Integer id, ServicioDTO dto);
    void subirImagenServicio(Integer id, MultipartFile archivo);
    void desactivarServicio(Integer id);

    // Skills de servicio
    List<ServicioSkillDTO> obtenerSkillsPorServicio(Integer servicioId);
    ServicioSkillDTO asignarSkillAServicio(Integer servicioId, Integer skillId);
    void quitarSkillDeServicio(Integer servicioId, Integer skillId);

}
