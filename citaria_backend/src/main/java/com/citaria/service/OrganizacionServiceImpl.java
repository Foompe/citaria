package com.citaria.service;

import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.ConfiguracionVisual;
import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import com.citaria.model.OrganizacionHorarioCierre;
import com.citaria.repository.ConfiguracionVisualDAO;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.OrganizacionHorarioCierreDAO;
import com.citaria.repository.OrganizacionHorarioDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Implementación del servicio de gestión de organizaciones.
 * Incluye gestión de horarios, cierres y configuración visual.
 */
@Service
public class OrganizacionServiceImpl implements OrganizacionService {

    private final OrganizacionDAO organizacionDAO;
    private final ConfiguracionVisualDAO configuracionVisualDAO;
    private final OrganizacionHorarioDAO organizacionHorarioDAO;
    private final OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO;
    private final ContextoSeguridad contextoSeguridad;

    public OrganizacionServiceImpl(OrganizacionDAO organizacionDAO,
                                   ConfiguracionVisualDAO configuracionVisualDAO,
                                   OrganizacionHorarioDAO organizacionHorarioDAO,
                                   OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO,
                                   ContextoSeguridad contextoSeguridad) {
        this.organizacionDAO = organizacionDAO;
        this.configuracionVisualDAO = configuracionVisualDAO;
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.organizacionHorarioCierreDAO = organizacionHorarioCierreDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    // ORGANIZACIÓN

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionDTO> obtenerTodas() {
        List<Organizacion> organizaciones = organizacionDAO.findAll();
        List<OrganizacionDTO> organizacionesDTO = new ArrayList<>();
        for (Organizacion organizacion : organizaciones) {
            organizacionesDTO.add(convertirOrganizacionADTO(organizacion));
        }
        return organizacionesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public OrganizacionDTO obtenerPorId(Integer id) {
        Organizacion organizacion = organizacionDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + id + " no encontrada"));
        return convertirOrganizacionADTO(organizacion);
    }

    /**
     * {@inheritDoc}
     *
     * El tokenRegistro se genera automáticamente con UUID — el admin no lo elige.
     * Esto garantiza que sea único, opaco e impredecible.
     */
    @Override
    @Transactional
    public OrganizacionDTO crear(OrganizacionDTO dto) {
        Organizacion organizacion = convertirOrganizacionAEntidad(dto);
        organizacion.setTokenRegistro(UUID.randomUUID().toString().replace("-", ""));
        return convertirOrganizacionADTO(organizacionDAO.save(organizacion));
    }

    @Override
    @Transactional
    public OrganizacionDTO actualizar(Integer id, OrganizacionDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + id + " no encontrada"));
        actualizarCamposOrganizacion(organizacion, dto);
        return convertirOrganizacionADTO(organizacionDAO.save(organizacion));
    }

    @Override
    @Transactional
    public boolean eliminar(Integer id) {
        if (organizacionDAO.existsById(id)) {
            organizacionDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // CONFIGURACIÓN VISUAL

    @Override
    @Transactional(readOnly = true)
    public ConfiguracionVisualDTO obtenerConfiguracionPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        ConfiguracionVisual configuracion = configuracionVisualDAO.findByOrganizacion(organizacion)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Configuración visual no encontrada para la organización " + organizacionId));
        return convertirConfiguracionADTO(configuracion);
    }

    @Override
    @Transactional
    public ConfiguracionVisualDTO crearConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        ConfiguracionVisual configuracion = convertirConfiguracionAEntidad(dto);
        configuracion.setOrganizacion(organizacion);
        return convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion));
    }

    @Override
    @Transactional
    public ConfiguracionVisualDTO actualizarConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        ConfiguracionVisual configuracion = configuracionVisualDAO.findByOrganizacion(organizacion)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Configuración visual no encontrada para la organización " + organizacionId));
        actualizarCamposConfiguracion(configuracion, dto);
        return convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion));
    }

    // HORARIOS

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioDTO> obtenerHorariosPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<OrganizacionHorario> horarios = organizacionHorarioDAO.findByOrganizacion(organizacion);
        List<OrganizacionHorarioDTO> horariosDTO = new ArrayList<>();
        for (OrganizacionHorario horario : horarios) {
            horariosDTO.add(convertirHorarioADTO(horario));
        }
        return horariosDTO;
    }

    @Override
    @Transactional
    public OrganizacionHorarioDTO crearHorario(Integer organizacionId, OrganizacionHorarioDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        OrganizacionHorario horario = convertirHorarioAEntidad(dto);
        horario.setOrganizacion(organizacion);
        return convertirHorarioADTO(organizacionHorarioDAO.save(horario));
    }

    @Override
    @Transactional
    public OrganizacionHorarioDTO actualizarHorario(Integer id, OrganizacionHorarioDTO dto) {
        OrganizacionHorario horario = organizacionHorarioDAO.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Horario con id " + id + " no encontrado"));
        actualizarCamposHorario(horario, dto);
        return convertirHorarioADTO(organizacionHorarioDAO.save(horario));
    }

    @Override
    @Transactional
    public boolean eliminarHorario(Integer id) {
        if (organizacionHorarioDAO.existsById(id)) {
            organizacionHorarioDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // CIERRES

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioCierreDTO> obtenerCierresPorOrganizacion(Integer organizacionId) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        List<OrganizacionHorarioCierre> cierres = organizacionHorarioCierreDAO.findByOrganizacion(organizacion);
        List<OrganizacionHorarioCierreDTO> cierresDTO = new ArrayList<>();
        for (OrganizacionHorarioCierre cierre : cierres) {
            cierresDTO.add(convertirCierreADTO(cierre));
        }
        return cierresDTO;
    }

    @Override
    @Transactional
    public OrganizacionHorarioCierreDTO crearCierre(Integer organizacionId, OrganizacionHorarioCierreDTO dto) {
        Organizacion organizacion = organizacionDAO.findById(organizacionId)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Organización con id " + organizacionId + " no encontrada"));
        OrganizacionHorarioCierre cierre = convertirCierreAEntidad(dto);
        cierre.setOrganizacion(organizacion);
        return convertirCierreADTO(organizacionHorarioCierreDAO.save(cierre));
    }

    @Override
    @Transactional
    public boolean eliminarCierre(Integer id) {
        if (organizacionHorarioCierreDAO.existsById(id)) {
            organizacionHorarioCierreDAO.deleteById(id);
            return true;
        }
        return false;
    }

    // CONVERSIONES

    private OrganizacionDTO convertirOrganizacionADTO(Organizacion organizacion) {
        OrganizacionDTO dto = new OrganizacionDTO();
        dto.setId(organizacion.getId());
        dto.setNombre(organizacion.getNombre());
        dto.setEmail(organizacion.getEmail());
        dto.setTelefono(organizacion.getTelefono());
        dto.setCif(organizacion.getCif());
        dto.setCalle(organizacion.getCalle());
        dto.setCodigoPostal(organizacion.getCodigoPostal());
        dto.setCiudad(organizacion.getCiudad());
        dto.setPais(organizacion.getPais());
        dto.setTokenRegistro(organizacion.getTokenRegistro());
        return dto;
    }

    private Organizacion convertirOrganizacionAEntidad(OrganizacionDTO dto) {
        Organizacion organizacion = new Organizacion();
        organizacion.setNombre(dto.getNombre());
        organizacion.setEmail(dto.getEmail());
        organizacion.setTelefono(dto.getTelefono());
        organizacion.setCif(dto.getCif());
        organizacion.setCalle(dto.getCalle());
        organizacion.setCodigoPostal(dto.getCodigoPostal());
        organizacion.setCiudad(dto.getCiudad());
        organizacion.setPais(dto.getPais());
        return organizacion;
    }

    private void actualizarCamposOrganizacion(Organizacion organizacion, OrganizacionDTO dto) {
        organizacion.setNombre(dto.getNombre());
        organizacion.setEmail(dto.getEmail());
        organizacion.setTelefono(dto.getTelefono());
        organizacion.setCif(dto.getCif());
        organizacion.setCalle(dto.getCalle());
        organizacion.setCodigoPostal(dto.getCodigoPostal());
        organizacion.setCiudad(dto.getCiudad());
        organizacion.setPais(dto.getPais());
    }

    private ConfiguracionVisualDTO convertirConfiguracionADTO(ConfiguracionVisual configuracion) {
        ConfiguracionVisualDTO dto = new ConfiguracionVisualDTO();
        dto.setId(configuracion.getId());
        dto.setOrganizacionId(configuracion.getOrganizacion().getId());
        dto.setLogoUrl(configuracion.getLogoUrl());
        dto.setFaviconUrl(configuracion.getFaviconUrl());
        dto.setIconoAppUrl(configuracion.getIconoAppUrl());
        dto.setColorPrimario(configuracion.getColorPrimario());
        dto.setColorSecundario(configuracion.getColorSecundario());
        dto.setTipografia(configuracion.getTipografia());
        return dto;
    }

    private ConfiguracionVisual convertirConfiguracionAEntidad(ConfiguracionVisualDTO dto) {
        ConfiguracionVisual configuracion = new ConfiguracionVisual();
        configuracion.setLogoUrl(dto.getLogoUrl());
        configuracion.setFaviconUrl(dto.getFaviconUrl());
        configuracion.setIconoAppUrl(dto.getIconoAppUrl());
        configuracion.setColorPrimario(dto.getColorPrimario());
        configuracion.setColorSecundario(dto.getColorSecundario());
        configuracion.setTipografia(dto.getTipografia());
        return configuracion;
    }

    private void actualizarCamposConfiguracion(ConfiguracionVisual configuracion, ConfiguracionVisualDTO dto) {
        configuracion.setLogoUrl(dto.getLogoUrl());
        configuracion.setFaviconUrl(dto.getFaviconUrl());
        configuracion.setIconoAppUrl(dto.getIconoAppUrl());
        configuracion.setColorPrimario(dto.getColorPrimario());
        configuracion.setColorSecundario(dto.getColorSecundario());
        configuracion.setTipografia(dto.getTipografia());
    }

    private OrganizacionHorarioDTO convertirHorarioADTO(OrganizacionHorario horario) {
        OrganizacionHorarioDTO dto = new OrganizacionHorarioDTO();
        dto.setId(horario.getId());
        dto.setOrganizacionId(horario.getOrganizacion().getId());
        dto.setDiaSemana(horario.getDiaSemana());
        dto.setHoraApertura(horario.getHoraApertura());
        dto.setHoraCierre(horario.getHoraCierre());
        dto.setActivo(horario.getActivo());
        return dto;
    }

    private OrganizacionHorario convertirHorarioAEntidad(OrganizacionHorarioDTO dto) {
        OrganizacionHorario horario = new OrganizacionHorario();
        horario.setDiaSemana(dto.getDiaSemana());
        horario.setHoraApertura(dto.getHoraApertura());
        horario.setHoraCierre(dto.getHoraCierre());
        horario.setActivo(dto.getActivo() != null ? dto.getActivo() : true);
        return horario;
    }

    private void actualizarCamposHorario(OrganizacionHorario horario, OrganizacionHorarioDTO dto) {
        horario.setDiaSemana(dto.getDiaSemana());
        horario.setHoraApertura(dto.getHoraApertura());
        horario.setHoraCierre(dto.getHoraCierre());
        horario.setActivo(dto.getActivo());
    }

    private OrganizacionHorarioCierreDTO convertirCierreADTO(OrganizacionHorarioCierre cierre) {
        OrganizacionHorarioCierreDTO dto = new OrganizacionHorarioCierreDTO();
        dto.setId(cierre.getId());
        dto.setOrganizacionId(cierre.getOrganizacion().getId());
        dto.setFecha(cierre.getFecha());
        dto.setMotivo(cierre.getMotivo());
        return dto;
    }

    private OrganizacionHorarioCierre convertirCierreAEntidad(OrganizacionHorarioCierreDTO dto) {
        OrganizacionHorarioCierre cierre = new OrganizacionHorarioCierre();
        cierre.setFecha(dto.getFecha());
        cierre.setMotivo(dto.getMotivo());
        return cierre;
    }
}