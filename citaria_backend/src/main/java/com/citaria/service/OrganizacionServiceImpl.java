package com.citaria.service;

import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.dto.OrganizacionPublicaDTO;
import com.citaria.exception.RecursoNoEncontradoException;
import com.citaria.model.*;
import com.citaria.repository.ConfiguracionVisualDAO;
import com.citaria.repository.OrganizacionDAO;
import com.citaria.repository.OrganizacionHorarioCierreDAO;
import com.citaria.repository.OrganizacionHorarioDAO;
import com.citaria.repository.ReservaDAO;
import com.citaria.repository.ReservaServicioDAO;
import com.citaria.security.ContextoSeguridad;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Implementación del servicio de gestión de organizaciones.
 */
@Service
public class OrganizacionServiceImpl implements OrganizacionService {

    private final OrganizacionDAO organizacionDAO;
    private final ConfiguracionVisualDAO configuracionVisualDAO;
    private final OrganizacionHorarioDAO organizacionHorarioDAO;
    private final OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO;
    private final ReservaDAO reservaDAO;
    private final ReservaServicioDAO reservaServicioDAO;
    private final ContextoSeguridad contextoSeguridad;

    @Autowired
    public OrganizacionServiceImpl(OrganizacionDAO organizacionDAO,
                                   ConfiguracionVisualDAO configuracionVisualDAO,
                                   OrganizacionHorarioDAO organizacionHorarioDAO,
                                   OrganizacionHorarioCierreDAO organizacionHorarioCierreDAO,
                                   ReservaDAO reservaDAO,
                                   ReservaServicioDAO reservaServicioDAO,
                                   ContextoSeguridad contextoSeguridad) {
        this.organizacionDAO = organizacionDAO;
        this.configuracionVisualDAO = configuracionVisualDAO;
        this.organizacionHorarioDAO = organizacionHorarioDAO;
        this.organizacionHorarioCierreDAO = organizacionHorarioCierreDAO;
        this.reservaDAO = reservaDAO;
        this.reservaServicioDAO = reservaServicioDAO;
        this.contextoSeguridad = contextoSeguridad;
    }

    // ORGANIZACIÓN

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionPublicaDTO> obtenerPublicas() {
        List<Organizacion> organizaciones = organizacionDAO.findAll();
        List<OrganizacionPublicaDTO> organizacionesDTO = new ArrayList<>();
        for (Organizacion organizacion : organizaciones) {
            Optional<ConfiguracionVisual> configuracionOptional = configuracionVisualDAO.findByOrganizacion(organizacion);
            organizacionesDTO.add(convertirOrganizacionAPublicaDTO(organizacion, configuracionOptional));
        }
        return organizacionesDTO;
    }

    @Override
    @Transactional(readOnly = true)
    public OrganizacionDTO obtenerPorId(Integer id) {
        verificarPertenencia(id);
        Organizacion organizacion = cargarOrganizacion(id);
        return convertirOrganizacionADTO(organizacion);
    }

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
        verificarPertenencia(id);
        Organizacion organizacion = cargarOrganizacion(id);
        actualizarCamposOrganizacion(organizacion, dto);
        return convertirOrganizacionADTO(organizacionDAO.save(organizacion));
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        verificarPertenencia(id);
        Organizacion organizacion = cargarOrganizacion(id);
        organizacionDAO.delete(organizacion);
    }

    // CONFIGURACIÓN VISUAL

    @Override
    @Transactional(readOnly = true)
    public ConfiguracionVisualDTO obtenerConfiguracionPorToken(String tokenRegistro) {
        Optional<Organizacion> organizacionOptional = organizacionDAO.findByTokenRegistro(tokenRegistro);
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Organización no encontrada para el token proporcionado");
        }
        Organizacion organizacion = organizacionOptional.get();
        Optional<ConfiguracionVisual> configuracionOptional = configuracionVisualDAO.findByOrganizacion(organizacion);
        if (configuracionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Configuración visual no encontrada para la organización");
        }
        return convertirConfiguracionADTO(configuracionOptional.get());
    }

    @Override
    @Transactional(readOnly = true)
    public ConfiguracionVisualDTO obtenerConfiguracionPublicaPorOrganizacionId(Integer organizacionId) {
        Organizacion organizacion = cargarOrganizacion(organizacionId);
        Optional<ConfiguracionVisual> configuracionOptional = configuracionVisualDAO.findByOrganizacion(organizacion);
        if (configuracionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Configuración visual no encontrada para la organización");
        }
        return convertirConfiguracionADTO(configuracionOptional.get());
    }

    @Override
    @Transactional
    public ConfiguracionVisualDTO crearConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);
        ConfiguracionVisual configuracion = convertirConfiguracionAEntidad(dto);
        configuracion.setOrganizacion(organizacion);
        return convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion));
    }

    @Override
    @Transactional
    public ConfiguracionVisualDTO actualizarConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto) {
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);
        Optional<ConfiguracionVisual> configuracionOptional = configuracionVisualDAO.findByOrganizacion(organizacion);
        if (configuracionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException(
                    "Configuración visual no encontrada para la organización " + organizacionId);
        }
        ConfiguracionVisual configuracion = configuracionOptional.get();
        actualizarCamposConfiguracion(configuracion, dto);
        return convertirConfiguracionADTO(configuracionVisualDAO.save(configuracion));
    }

    // HORARIOS

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioDTO> obtenerHorariosPorOrganizacion(Integer organizacionId) {
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);
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
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);
        OrganizacionHorario horario = convertirHorarioAEntidad(dto);
        horario.setOrganizacion(organizacion);
        return convertirHorarioADTO(organizacionHorarioDAO.save(horario));
    }

    @Override
    @Transactional
    public OrganizacionHorarioDTO actualizarHorario(Integer id, OrganizacionHorarioDTO dto) {
        OrganizacionHorario horario = cargarHorario(id);
        verificarPertenencia(horario.getOrganizacion().getId());
        actualizarCamposHorario(horario, dto);
        return convertirHorarioADTO(organizacionHorarioDAO.save(horario));
    }

    @Override
    @Transactional
    public void eliminarHorario(Integer id) {
        OrganizacionHorario horario = cargarHorario(id);
        verificarPertenencia(horario.getOrganizacion().getId());
        organizacionHorarioDAO.deleteById(id);
    }

    // CIERRES

    @Override
    @Transactional(readOnly = true)
    public List<OrganizacionHorarioCierreDTO> obtenerCierresPorOrganizacion(Integer organizacionId) {
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);
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
        verificarPertenencia(organizacionId);
        Organizacion organizacion = cargarOrganizacion(organizacionId);

        // Cancelar en la misma transacción las reservas activas de esa fecha
        List<EstadoReserva> estadosActivos = new ArrayList<>();
        estadosActivos.add(EstadoReserva.pendiente);
        estadosActivos.add(EstadoReserva.confirmada);

        List<Reserva> afectadas = reservaDAO.findByOrganizacionAndFechaAndEstadoIn(
                organizacion, dto.getFecha(), estadosActivos);
        for (Reserva reserva : afectadas) {
            reserva.setEstado(EstadoReserva.cancelada);
            reserva.setMotivo("Cierre del establecimiento");
            reservaServicioDAO.cancelarDetallesPorReserva(reserva, EstadoReservaServicio.cancelado);
        }

        OrganizacionHorarioCierre cierre = convertirCierreAEntidad(dto);
        cierre.setOrganizacion(organizacion);
        return convertirCierreADTO(organizacionHorarioCierreDAO.save(cierre));
    }

    @Override
    @Transactional
    public void eliminarCierre(Integer id) {
        OrganizacionHorarioCierre cierre = cargarCierre(id);
        verificarPertenencia(cierre.getOrganizacion().getId());
        organizacionHorarioCierreDAO.deleteById(id);
    }

    // VERIFICACIÓN DE PERTENENCIA

    /**
     * Verifica que el organizacionId recibido coincide con la organización
     * del usuario autenticado en el JWT.
     */
    private void verificarPertenencia(Integer organizacionId) {
        Integer organizacionIdActual = contextoSeguridad.obtenerOrganizacionIdActual();
        if (!organizacionIdActual.equals(organizacionId)) {
            throw new RecursoNoEncontradoException("Organización con id " + organizacionId + " no encontrada");
        }
    }

    private Organizacion cargarOrganizacion(Integer id) {
        Optional<Organizacion> organizacionOptional = organizacionDAO.findById(id);
        if (organizacionOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Organización con id " + id + " no encontrada");
        }
        return organizacionOptional.get();
    }

    private OrganizacionHorario cargarHorario(Integer id) {
        Optional<OrganizacionHorario> horarioOptional = organizacionHorarioDAO.findById(id);
        if (horarioOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Horario con id " + id + " no encontrado");
        }
        return horarioOptional.get();
    }

    private OrganizacionHorarioCierre cargarCierre(Integer id) {
        Optional<OrganizacionHorarioCierre> cierreOptional = organizacionHorarioCierreDAO.findById(id);
        if (cierreOptional.isEmpty()) {
            throw new RecursoNoEncontradoException("Cierre con id " + id + " no encontrado");
        }
        return cierreOptional.get();
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

    private OrganizacionPublicaDTO convertirOrganizacionAPublicaDTO(Organizacion organizacion,
                                                                    Optional<ConfiguracionVisual> configuracionOptional) {
        OrganizacionPublicaDTO dto = new OrganizacionPublicaDTO();
        dto.setId(organizacion.getId());
        dto.setNombre(organizacion.getNombre());
        dto.setTokenRegistro(organizacion.getTokenRegistro());
        if (configuracionOptional.isPresent()) {
            dto.setLogoUrl(configuracionOptional.get().getLogoUrl());
        } else {
            dto.setLogoUrl(null);
        }
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
        dto.setVersion(configuracion.getVersion());
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
        if (dto.getActivo() != null) {
            horario.setActivo(dto.getActivo());
        } else {
            horario.setActivo(true);
        }
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
