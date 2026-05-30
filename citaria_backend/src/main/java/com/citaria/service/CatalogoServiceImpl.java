package com.citaria.service;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioHabilidadDTO;
import com.citaria.dto.HabilidadDTO;
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
    private final HabilidadDAO habilidadDAO;
    private final ServicioDAO servicioDAO;
    private final ServicioHabilidadDAO servicioHabilidadDAO;
    private final ContextoSeguridad contextoSeguridad;
    private final ImagenService imagenService;

    @Autowired
    public CatalogoServiceImpl(CategoriaDAO categoriaDAO,
                               HabilidadDAO habilidadDAO,
                               ServicioDAO servicioDAO,
                               ServicioHabilidadDAO servicioHabilidadDAO,
                               ContextoSeguridad contextoSeguridad,
                               ImagenService imagenService) {
        this.categoriaDAO = categoriaDAO;
        this.habilidadDAO = habilidadDAO;
        this.servicioDAO = servicioDAO;
        this.servicioHabilidadDAO = servicioHabilidadDAO;
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

    // HABILIDADES

    @Override
    @Transactional(readOnly = true)
    public List<HabilidadDTO> obtenerHabilidades() {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        List<Habilidad> habilidades = habilidadDAO.findByOrganizacion(organizacion);
        List<HabilidadDTO> habilidadesDTO = new ArrayList<>();
        for (Habilidad habilidad : habilidades) {
            habilidadesDTO.add(convertirHabilidadADTO(habilidad));
        }
        return habilidadesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public HabilidadDTO obtenerHabilidadPorId(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(id);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + id + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        return convertirHabilidadADTO(habilidad);
    }

    @Override
    @Transactional
    public HabilidadDTO crearHabilidad(HabilidadDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Habilidad habilidad = convertirHabilidadAEntidad(dto);
        habilidad.setOrganizacion(organizacion);
        return convertirHabilidadADTO(habilidadDAO.save(habilidad));
    }

    @Override
    @Transactional
    public HabilidadDTO actualizarHabilidad(Integer id, HabilidadDTO dto) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(id);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + id + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        habilidad.setNombre(dto.getNombre());
        habilidad.setDescripcion(dto.getDescripcion());
        return convertirHabilidadADTO(habilidadDAO.save(habilidad));
    }

    @Override
    @Transactional
    public void desactivarHabilidad(Integer id) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(id);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + id + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        habilidad.setActivo(false);
        habilidadDAO.save(habilidad);
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

    // HABILIDADES DE SERVICIO

    @Override
    @Transactional(readOnly = true)
    public List<ServicioHabilidadDTO> obtenerHabilidadesPorServicio(Integer servicioId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        List<ServicioHabilidad> habilidades = servicioHabilidadDAO.findByServicio(servicio);
        List<ServicioHabilidadDTO> habilidadesDTO = new ArrayList<>();
        for (ServicioHabilidad servicioHabilidad : habilidades) {
            habilidadesDTO.add(convertirServicioHabilidadADTO(servicioHabilidad));
        }
        return habilidadesDTO;
    }

    @Override
    @Transactional
    public ServicioHabilidadDTO asignarHabilidadAServicio(Integer servicioId, Integer habilidadId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(habilidadId);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + habilidadId + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        ServicioHabilidad servicioHabilidad = new ServicioHabilidad(servicio, habilidad);
        return convertirServicioHabilidadADTO(servicioHabilidadDAO.save(servicioHabilidad));
    }

    @Override
    @Transactional
    public void quitarHabilidadDeServicio(Integer servicioId, Integer habilidadId) {
        Organizacion organizacion = contextoSeguridad.obtenerOrganizacionActual();
        Optional<Servicio> servicioOptional = servicioDAO.findById(servicioId);
        if (servicioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Servicio con id " + servicioId + " no encontrado");
        }
        Servicio servicio = servicioOptional.get();
        verificarPerenenciaServicio(servicio, organizacion);
        Optional<Habilidad> habilidadOptional = habilidadDAO.findById(habilidadId);
        if (habilidadOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Habilidad con id " + habilidadId + " no encontrada");
        }
        Habilidad habilidad = habilidadOptional.get();
        verificarPertenenciaHabilidad(habilidad, organizacion);
        ServicioHabilidadId servicioHabilidadId = new ServicioHabilidadId(servicioId, habilidadId);
        if (!servicioHabilidadDAO.existsById(servicioHabilidadId)) {
            throw new RecursoNoEncontradoException(
                    "Asignación de habilidad " + habilidadId + " al servicio " + servicioId + " no encontrada");
        }
        servicioHabilidadDAO.deleteById(servicioHabilidadId);
    }

    //      MÉTODOS AUXILIARES


    // VERIFICACIÓN DE PERTENENCIA

    private void verificarPertenenciaCategoria(Categoria categoria, Organizacion organizacion) {
        if (!categoria.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Categoría con id " + categoria.getId() + " no encontrada");
        }
    }

    private void verificarPertenenciaHabilidad(Habilidad habilidad, Organizacion organizacion) {
        if (!habilidad.getOrganizacion().getId().equals(organizacion.getId())) {
            throw new RecursoNoEncontradoException("Habilidad con id " + habilidad.getId() + " no encontrada");
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

    private HabilidadDTO convertirHabilidadADTO(Habilidad habilidad) {
        HabilidadDTO dto = new HabilidadDTO();
        dto.setId(habilidad.getId());
        dto.setOrganizacionId(habilidad.getOrganizacion().getId());
        dto.setNombre(habilidad.getNombre());
        dto.setDescripcion(habilidad.getDescripcion());
        dto.setActivo(habilidad.getActivo());
        return dto;
    }

    private Habilidad convertirHabilidadAEntidad(HabilidadDTO dto) {
        Habilidad habilidad = new Habilidad();
        habilidad.setNombre(dto.getNombre());
        habilidad.setDescripcion(dto.getDescripcion());
        if (dto.getActivo() != null) {
            habilidad.setActivo(dto.getActivo());
        } else {
            habilidad.setActivo(true);
        }
        return habilidad;
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

    private ServicioHabilidadDTO convertirServicioHabilidadADTO(ServicioHabilidad servicioHabilidad) {
        ServicioHabilidadDTO dto = new ServicioHabilidadDTO();
        dto.setServicioId(servicioHabilidad.getServicio().getId());
        dto.setHabilidadId(servicioHabilidad.getHabilidad().getId());
        dto.setNombreHabilidad(servicioHabilidad.getHabilidad().getNombre());
        return dto;
    }
}
