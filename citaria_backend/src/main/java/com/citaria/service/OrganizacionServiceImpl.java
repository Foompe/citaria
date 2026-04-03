package com.citaria.service;

import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.model.ConfiguracionVisual;
import com.citaria.model.Organizacion;
import com.citaria.model.OrganizacionHorario;
import com.citaria.model.OrganizacionHorarioCierre;
import com.citaria.repository.ConfiguracionVisualDAO;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.OrganizacionHorarioCierreDAO;
import com.citaria.repository.OrganizacionHorarioDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de gestión de organizaciones.
 * Incluye gestión de horarios, cierres y configuración visual.
 */
@Service
public class OrganizacionServiceImpl implements OrganizacionService {

    private OrganizacionDAO organizacionDAO;
    private ConfiguracionVisualDAO configuracionVisualDAO;
    private OrganizacionHorarioDAO organizacionHorarioDAO;
    private OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO;

    @Autowired
    public OrganizacionServiceImpl(OrganizacionDAO organizacionDAO,
                                   ConfiguracionVisualDAO configuracionVisualDAO,
                                   OrganizacionHorarioDAO organizacionHorarioDAO,
                                   OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO) {
        this.organizacionDAO = organizacionDAO;
        this.configuracionVisualDAO = configuracionVisualDAO;
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.organizacionHorarioCierreDAO = organizacionHorarioCierreDAO;
    }

    // ===== ORGANIZACIÓN =====

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
    public Optional<OrganizacionDTO> obtenerPorId(Integer id) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(id);
        if (organizacion.isPresent()) {
            return Optional.of(convertirOrganizacionADTO(organizacion.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public OrganizacionDTO crear(OrganizacionDTO dto) {
        Organizacion organizacion = convertirOrganizacionAEntidad(dto);
        return convertirOrganizacionADTO(organizacionDAO.save(organizacion));
    }

    @Override
    @Transactional
    public Optional<OrganizacionDTO> actualizar(Integer id, OrganizacionDTO dto) {
        Optional<Organizacion> existente = organizacionDAO.findById(id);
        if (existente.isPresent()) {
            Organizacion organizacion = existente.get();
            organizacion.setNombre(dto.getNombre());
            organizacion.setEmail(dto.getEmail());
            organizacion.setTelefono(dto.getTelefono());
            organizacion.setCif(dto.getCif());
            organizacion.setCalle(dto.getCalle());
            organizacion.setCodigoPostal(dto.getCodigoPostal());
            organizacion.setCiudad(dto.getCiudad());
            organizacion.setPais(dto.getPais());
            return Optional.of(convertirOrganizacionADTO(organizacionDAO.save(organizacion)));
        }
        return Optional.empty();
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

    // ===== CONFIGURACIÓN VISUAL =====

    @Override
    @Transactional(readOnly = true)
    public Optional<ConfiguracionVisualDTO> obtenerConfiguracionPorOrganizacion(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        if (organizacion.isPresent()) {
            Optional<ConfiguracionVisual> configuracion = configuracionVisualDAO.findByOrganizacion(organizacion.get());
            if (configuracion.isPresent()) {
                return Optional.of(convertirConfiguracionADTO(configuracion.get()));
            }
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public ConfiguracionVisualDTO crearConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        ConfiguracionVisual configuracion = convertirConfiguracionAEntidad(dto);
        configuracion.setOrganizacion(organizacion.get());
        return convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion));
    }

    @Override
    @Transactional
    public Optional<ConfiguracionVisualDTO> actualizarConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        if (organizacion.isPresent()) {
            Optional<ConfiguracionVisual> existente = configuracionVisualDAO.findByOrganizacion(organizacion.get());
            if (existente.isPresent()) {
                ConfiguracionVisual configuracion = existente.get();
                configuracion.setLogoUrl(dto.getLogoUrl());
                configuracion.setFaviconUrl(dto.getFaviconUrl());
                configuracion.setIconoAppUrl(dto.getIconoAppUrl());
                configuracion.setColorPrimario(dto.getColorPrimario());
                configuracion.setColorSecundario(dto.getColorSecundario());
                configuracion.setTipografia(dto.getTipografia());
                return Optional.of(convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion)));
            }
        }
        return Optional.empty();
    }

    // ===== HORARIOS =====

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioDTO> obtenerHorariosPorOrganizacion(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<OrganizacionHorarioDTO> horariosDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<OrganizacionHorario> horarios = organizacionHorarioDAO.findByOrganizacion(organizacion.get());
            for (OrganizacionHorario horario : horarios) {
                horariosDTO.add(convertirHorarioADTO(horario));
            }
        }
        return horariosDTO;
    }

    @Override
    @Transactional
    public OrganizacionHorarioDTO crearHorario(Integer organizacionId, OrganizacionHorarioDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        OrganizacionHorario horario = convertirHorarioAEntidad(dto);
        horario.setOrganizacion(organizacion.get());
        return convertirHorarioADTO(organizacionHorarioDAO.save(horario));
    }

    @Override
    @Transactional
    public Optional<OrganizacionHorarioDTO> actualizarHorario(Integer id, OrganizacionHorarioDTO dto) {
        Optional<OrganizacionHorario> existente = organizacionHorarioDAO.findById(id);
        if (existente.isPresent()) {
            OrganizacionHorario horario = existente.get();
            horario.setDiaSemana(dto.getDiaSemana());
            horario.setHoraApertura(dto.getHoraApertura());
            horario.setHoraCierre(dto.getHoraCierre());
            horario.setActivo(dto.getActivo());
            return Optional.of(convertirHorarioADTO(organizacionHorarioDAO.save(horario)));
        }
        return Optional.empty();
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

    // ===== CIERRES =====

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioCierreDTO> obtenerCierresPorOrganizacion(Integer organizacionId) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        List<OrganizacionHorarioCierreDTO> cierresDTO = new ArrayList<>();
        if (organizacion.isPresent()) {
            List<OrganizacionHorarioCierre> cierres = organizacionHorarioCierreDAO.findByOrganizacion(organizacion.get());
            for (OrganizacionHorarioCierre cierre : cierres) {
                cierresDTO.add(convertirCierreADTO(cierre));
            }
        }
        return cierresDTO;
    }

    @Override
    @Transactional
    public OrganizacionHorarioCierreDTO crearCierre(Integer organizacionId, OrganizacionHorarioCierreDTO dto) {
        Optional<Organizacion> organizacion = organizacionDAO.findById(organizacionId);
        OrganizacionHorarioCierre cierre = convertirCierreAEntidad(dto);
        cierre.setOrganizacion(organizacion.get());
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

    // ===== CONVERSIONES =====

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