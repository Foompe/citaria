package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioHabilidadDTO;
import com.citaria.dto.HabilidadDTO;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * Servicio de gestión de servicios, categorías y habilidades.
 */
public interface CatalogoService {

    // Categorías
    List<CategoriaDTO> obtenerCategorias();
    CategoriaDTO obtenerCategoriaPorId(Integer id);
    CategoriaDTO crearCategoria(CategoriaDTO dto);
    CategoriaDTO actualizarCategoria(Integer id, CategoriaDTO dto);
    void desactivarCategoria(Integer id);

    // Habilidades
    List<HabilidadDTO> obtenerHabilidades();
    HabilidadDTO obtenerHabilidadPorId(Integer id);
    HabilidadDTO crearHabilidad(HabilidadDTO dto);
    HabilidadDTO actualizarHabilidad(Integer id, HabilidadDTO dto);
    void desactivarHabilidad(Integer id);

    // Servicios
    List<ServicioDTO> obtenerServicios();
    List<ServicioDTO> obtenerServiciosPorCategoria(Integer categoriaId);
    ServicioDTO obtenerServicioPorId(Integer id);
    ServicioDTO crearServicio(ServicioDTO dto);
    ServicioDTO actualizarServicio(Integer id, ServicioDTO dto);
    void subirImagenServicio(Integer id, MultipartFile archivo);
    void desactivarServicio(Integer id);

    // Habilidades de servicio
    List<ServicioHabilidadDTO> obtenerHabilidadesPorServicio(Integer servicioId);
    ServicioHabilidadDTO asignarHabilidadAServicio(Integer servicioId, Integer habilidadId);
    void quitarHabilidadDeServicio(Integer servicioId, Integer habilidadId);

}
